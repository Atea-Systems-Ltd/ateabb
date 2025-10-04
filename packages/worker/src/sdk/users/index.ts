export * from "./users"
import { users } from "@budibase/backend-core"
import * as pro from "@budibase/pro"
import { Feature } from "@budibase/types"
import { PlanType } from "packages/types/src/sdk/licensing/plan"

// Ensure free-plan user limits are overridden before UserDB.init runs
try {
  const licenses: any[] = [
    // self-hosted free license
    // @ts-ignore
    pro?.constants?.licenses?.SELF_FREE_LICENSE,
    // cloud free license (safe to update if present)
    // @ts-ignore
    pro?.constants?.licenses?.CLOUD_FREE_LICENSE,
  ].filter(Boolean)

  for (const lic of licenses) {
    if (lic?.quotas?.usage?.static?.users) {
      lic.quotas.usage.static.users.value = -1
    }
    if (lic?.quotas?.usage?.static?.userGroups) {
      lic.quotas.usage.static.userGroups.value = -1
    }
    // Enable desired features explicitly
    lic.features = [
      Feature.BRANDING,
      Feature.USER_GROUPS,
      Feature.OFFLINE,
      Feature.CUSTOM_APP_SCRIPTS,
      Feature.ENVIRONMENT_VARIABLES,
      Feature.PDF,
      Feature.PWA,
      Feature.SYNC_AUTOMATIONS,
      Feature.TRIGGER_AUTOMATION_RUN,
    ]
  }
} catch (err) {
  // non-fatal: if structure changes, continue with defaults
}
// pass in the components which are specific to the worker/the parts of pro which backend-core cannot access
//
//console.log("*********************************************")
//console.log(
//  "***** Initialising DB with quotas: \n" + JSON.stringify(pro, (key, value) => {
//	if(typeof value === 'function') {
//		return value.toString();
//	}
//	return value;
//  })
//)
// console.log("*********************************************")
// pro.constants.licenses.SELF_FREE_LICENSE.quotas.usage.static.users.value = -1
// //pro.constants.licenses.SELF_FREE_LICENSE.quotas.usage.static.userGroups.value = -1
// // Feature enum defined in ./packages/types/src/sdk/licensing/feature.ts
// //pro.constants.licenses.SELF_FREE_LICENSE.features = [ "environmentVariables", "userGroups", "branding","pwa","appBackups", "offline", "pdf" ]
// //pro.constants.licenses.SELF_FREE_LICENSE.features = [ "branding", "environmentVariables", "offline" ]
// pro.constants.licenses.SELF_FREE_LICENSE.features = [
//   Feature.BRANDING,
//   // Feature.ENVIRONMENT_VARIABLES,
//   Feature.OFFLINE,
//   // Feature.SYNC_AUTOMATIONS,
//   // Feature.TRIGGER_AUTOMATION_RUN,
//   // Feature.USER_GROUPS,
//   // Feature.PWA,
//   // Feature.PDF,
// ]
// PlanType enum defined in  ./packages/types/src/sdk/licensing/plan.ts
pro.constants.licenses.SELF_FREE_LICENSE.plan.type = PlanType.ENTERPRISE
users.UserDB.init(pro.quotas, pro.groups, pro.features)
export const db = users.UserDB
export { users as core } from "@budibase/backend-core"
