import { sdk as proSdk } from "@budibase/pro"
import * as pro from "@budibase/pro"
import { Feature } from "@budibase/types"
import { PlanType } from "packages/types/src/sdk/licensing/plan"

export const initPro = async () => {
  await proSdk.init({})

}
