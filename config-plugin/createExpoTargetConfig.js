const getAppGroupFromExpoConfig = require("./getAppGroupFromExpoConfig");

/**
 * Creates a configuration function for Apple target extensions
 * @param {('shield-action' | 'shield-configuration' | 'device-activity-monitor')} targetType - The type of target extension
 * @returns {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction}
 */
const createConfig = (targetType) => {
  /** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction} */
  const config = (config) => {
    const appGroup = getAppGroupFromExpoConfig(config);

    return {
      type: targetType,
      entitlements: {
        "com.apple.developer.family-controls": true,
        "com.apple.security.application-groups": [appGroup],
      },
    };
  };
  return config;
};

module.exports = { createConfig };
