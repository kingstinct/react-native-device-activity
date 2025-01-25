const { withXcodeProject } = require("@expo/config-plugins");
/*
const { XcodeProject } = require("@bacons/xcode");
const fs = require("fs");
const path = require("path");
*/

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string }>} */
const withXcodeSettings = (config, { appGroup }) => {
  return withXcodeProject(config, (newConfig) => {
    const xcodeProject = newConfig.modResults;

    const settings = {
      REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP: appGroup,
    };

    /*const projectRoot = config._internal.projectRoot;
    const iosPath = path.join(projectRoot, "ios");

    // Find the .xcodeproj file in the ios directory
    const xcodeprojFile = fs
      .readdirSync(iosPath)
      .find((file) => file.endsWith(".xcodeproj"));

    if (!xcodeprojFile) {
      throw new Error("Could not find .xcodeproj file in ios directory");
    }

    const xcodeprojPath = path.join(iosPath, xcodeprojFile, "project.pbxproj");

    const xcodeFile = XcodeProject.open(xcodeprojPath);

    // Get all targets
    const allTargets = xcodeFile.rootObject.props.targets;

    const mainTarget = allTargets.find(
      (target) =>
        target.props.productType === "com.apple.product-type.application",
    );

    const targetNames = [
      mainTarget.props.name,
      "ShieldAction",
      "ShieldConfiguration",
      "ActivityMonitorExtension",
    ];*/

    const configurations = xcodeProject.pbxXCBuildConfigurationSection();

    for (const key in configurations) {
      if (
        // todo: can't seem to get this filter 100% right, but this might be a spillover we could live with..
        typeof configurations[key].buildSettings !== "undefined" /*&&
        (targetNames.includes(configurations[key].buildSettings.PRODUCT_NAME) ||
          targetNames.some((target) =>
            configurations[
              key
            ].buildSettings?.PRODUCT_BUNDLE_IDENTIFIER?.includes(target),
          ))*/
      ) {
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
