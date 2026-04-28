import { sdk as proSdk } from "@budibase/pro"
import * as pro from "@budibase/pro"
import { Feature } from "@budibase/types"
import { PlanType } from "packages/types/src/sdk/licensing/plan"

export const initPro = async () => {
  await proSdk.init({})
    // Ensure both self-hosted and cloud free licenses reflect desired limits/features
  const freeLicenses = [
    pro.constants.licenses.SELF_FREE_LICENSE,
    pro.constants.licenses.CLOUD_FREE_LICENSE,
  ]

  for (const license of freeLicenses) {
    try {
      // Unlimited users (and keep other quotas as-is)
      if (license?.quotas?.usage?.static?.users) {
        license.quotas.usage.static.users.value = -1
      }
      // Enable desired features explicitly
      license.features = [
        Feature.BRANDING,
        Feature.OFFLINE,
        Feature.CUSTOM_APP_SCRIPTS,
        Feature.ENVIRONMENT_VARIABLES,
        Feature.PDF,
        Feature.PWA,
        Feature.SYNC_AUTOMATIONS,
        Feature.TRIGGER_AUTOMATION_RUN,
      ]
    } catch (err) {
      // swallow to avoid boot failure if license shape changes
    }
  }
}
