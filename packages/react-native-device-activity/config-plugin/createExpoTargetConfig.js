const getAppGroupFromExpoConfig = require("./getAppGroupFromExpoConfig");

/**
 * Creates a configuration function for Apple target extensions
 * @param {('shield-action' | 'shield-configuration' | 'device-activity-monitor' | 'device-activity-report')} targetType - The type of target extension
 * @returns {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction}
 */
const createConfig = (targetType) => {
  /** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction} */
  const config = (config) => {
    const appGroup = getAppGroupFromExpoConfig(config);

    /** @type {Record<string, any>} */
    const result = {
      type: targetType,
      entitlements: {
        "com.apple.developer.family-controls": true,
        "com.apple.security.application-groups": [appGroup],
      },
    };

    // expo-apple-targets doesn't natively support device-activity-report,
    // so we need to explicitly provide the required frameworks.
    // The Info.plist is provided by the target folder and won't be overwritten.
    if (targetType === "device-activity-report") {
      result.frameworks = ["DeviceActivity", "SwiftUI"];
    }

    return result;
  };
  return config;
};

module.exports = { createConfig };
