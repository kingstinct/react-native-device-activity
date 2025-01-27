const {
  default: getAppGroupFromExpoConfig,
} = require("react-native-device-activity/config-plugin/getAppGroupFromExpoConfig");

/** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction} */
const config = (config) => {
  const appGroup = getAppGroupFromExpoConfig(config);

  return {
    type: "shield-configuration",
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [appGroup],
    },
  };
};

module.exports = config;
