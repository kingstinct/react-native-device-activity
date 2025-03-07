const { withInfoPlist } = require("expo/config-plugins");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string }>} */
const withInfoPlistAppGroup = (config) => {
  return withInfoPlist(config, (config) => {
    config.modResults.REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP =
      "$(REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP)";
    return config;
  });
};

module.exports = withInfoPlistAppGroup;
