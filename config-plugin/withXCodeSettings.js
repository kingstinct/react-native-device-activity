const { withXcodeProject } = require("@expo/config-plugins");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string }>} */
const withXcodeSettings = (config, { appGroup }) => {
  return withXcodeProject(config, (newConfig) => {
    const xcodeProject = newConfig.modResults;

    const settings = {
      REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP: appGroup,
    };

    const configurations = xcodeProject.pbxXCBuildConfigurationSection();

    for (const key in configurations) {
      // could be trimmed down to main target + react-native-device-activity targets, but since it's the name is so specific this should be fine
      if (typeof configurations[key].buildSettings !== "undefined") {
        const buildSettingsObj = configurations[key].buildSettings;
        for (const key in settings) {
          buildSettingsObj[key] = settings[key];
        }
      }
    }
    return newConfig;
  });
};

module.exports = withXcodeSettings;
