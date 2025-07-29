export * from "./users"
import { users } from "@budibase/backend-core"
import * as pro from "@budibase/pro"
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
console.log("*********************************************")
pro.constants.licenses.SELF_FREE_LICENSE.quotas.usage.static.users.value = -1;
pro.constants.licenses.SELF_FREE_LICENSE.quotas.usage.static.userGroups.value = -1;
users.UserDB.init(pro.quotas, pro.groups, pro.features)
export const db = users.UserDB
export { users as core } from "@budibase/backend-core"
