export * from "./users"
import { users } from "@budibase/backend-core"
import * as pro from "@budibase/pro"

users.UserDB.init(pro.quotas, pro.groups, pro.features)
export const db = users.UserDB
export { users as core } from "@budibase/backend-core"
