import { UserRoles } from './../../../../../types/src/documents/global/user';
import { generateGlobalUserID } from "../../../db"
import { getAllApps } from "../../../db"
import { authError } from "../utils"
import * as users from "../../../users"
import * as context from "../../../context"
import { logWarn } from "../../../logging"
import {
  SaveSSOUserFunction,
  SSOAuthDetails,
  SSOUser,
  User,
} from "@budibase/types"

// no-op function for user save
// - this allows datasource auth and access token refresh to work correctly
// - prefer no-op over an optional argument to ensure function is provided to login flows
export const ssoSaveUserNoOp: SaveSSOUserFunction = (user: SSOUser) =>
  Promise.resolve(user)

/**
 * Common authentication logic for third parties. e.g. OAuth, OIDC.
 */
export async function authenticate(
  details: SSOAuthDetails,
  requireLocalAccount = true,
  done: any,
  saveUserFn: SaveSSOUserFunction
) {
  if (!saveUserFn) {
    throw new Error("Save user function must be provided")
  }
  if (!details.userId) {
    return authError(done, "sso user id required")
  }
  if (!details.email) {
    return authError(done, "sso user email required")
  }
  let ateaUserRoles: UserRoles = {}
  let allApps = await getAllApps()
  const APP_MAP_RAW: string = process.env.ATEA_APP_MAP || '' 
  const APP_MAP_ROLES: string[] = APP_MAP_RAW.split(",")
  const CUSTOM_CLAIM: string = details?.profile?._json?.custom_claim || ''
  if (CUSTOM_CLAIM) {
    let roles: string[] = CUSTOM_CLAIM.split(",")
    if (roles) {
      roles.forEach((element: string) => {
        APP_MAP_ROLES.forEach((role: string) => {
          let rolemap: string[] = role.split(":")
          if (rolemap[0] === element) {
            for (let app of allApps) {
              if (app.name === rolemap[2]) {
                logWarn(`SETTING ROLE: APPID: ${app.appId}, ROLEMAP: ${rolemap}`)
                const APPID: string = app.appId.replace('_dev', '')
                ateaUserRoles[APPID] = rolemap[1]
              }
            }
          }
        })
    });
    }
  }

  // use the third party id
  const userId = generateGlobalUserID(details.userId)

  let dbUser: User | undefined

  // try to load by id
  try {
    dbUser = await users.getById(userId)
  } catch (err: any) {
    // abort when not 404 error
    if (!err.status || err.status !== 404) {
      return authError(
        done,
        "Unexpected error when retrieving existing user",
        err
      )
    }
  }

  // fallback to loading by email
  if (!dbUser) {
    dbUser = await users.getGlobalUserByEmail(details.email)
  }

  // exit early if there is still no user and auto creation is disabled
  if (!dbUser && requireLocalAccount) {
    return authError(
      done,
      "Email does not yet exist. You must set up your local budibase account first."
    )
  }

  // first time creation
  if (!dbUser) {
    // setup a blank user using the third party id
    dbUser = {
      _id: userId,
      email: details.email,
      roles: {},
      tenantId: context.getTenantId(),
    }
  }
  // @ts-ignore
  dbUser.roles = ateaUserRoles
  let ssoUser = await syncUser(dbUser, details)
  // never prompt for password reset
  ssoUser.forceResetPassword = false

  try {
    // don't try to re-save any existing password
    delete ssoUser.password
    // create or sync the user
    ssoUser = (await saveUserFn(ssoUser, {
      hashPassword: false,
      requirePassword: false,
    })) as SSOUser
  } catch (err: any) {
    return authError(done, "Error saving user", err)
  }

  return done(null, ssoUser)
}

/**
 * @returns a user that has been sync'd with third party information
 */
async function syncUser(user: User, details: SSOAuthDetails): Promise<SSOUser> {
  let firstName
  let lastName
  let oauth2

  if (details.profile) {
    const profile = details.profile

    if (profile.name) {
      const name = profile.name
      // first name
      if (name.givenName) {
        firstName = name.givenName
      }
      // last name
      if (name.familyName) {
        lastName = name.familyName
      }
    }
  }

  // oauth tokens for future use
  if (details.oauth2) {
    oauth2 = {
      ...details.oauth2,
    }
  }

  return {
    ...user,
    provider: details.provider,
    providerType: details.providerType,
    firstName,
    lastName,
    oauth2,
  }
}

