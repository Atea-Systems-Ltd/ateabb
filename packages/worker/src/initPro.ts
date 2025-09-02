import { sdk as proSdk } from "@budibase/pro"

import * as pro from "@budibase/pro"
import { Feature } from "@budibase/types"

export const initPro = async () => {
  pro.constants.licenses.SELF_FREE_LICENSE.quotas.usage.static.users.value = -1
  pro.constants.licenses.SELF_FREE_LICENSE.features = [
    Feature.BRANDING,
    Feature.OFFLINE,
  ]
  await proSdk.init({})
}
