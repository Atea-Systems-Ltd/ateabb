import * as pro from "@budibase/pro"

export async function getLicensedConfig() {
  let licensedConfig: object = {}
  const defaults = {
    emailBrandingEnabled: true,
    testimonialsEnabled: true,
    platformTitle: "Ātea platform title",
    metaDescription: undefined,
    loginHeading: "Ātea login heading",
    loginButton: undefined,
    metaImageUrl: undefined,
    metaTitle: "Ātea meta title",
  }

  licensedConfig = { ...defaults }
/*
  try {
    // License/Feature Checks
    const enabled = await pro.features.isBrandingEnabled()
    if (!enabled) {
      licensedConfig = { ...defaults }
    }
  } catch (e) {
    licensedConfig = { ...defaults }
    console.info("Could not retrieve license", e)
  }
*/
  return licensedConfig
}
