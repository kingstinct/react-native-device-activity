/** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').Config} */
const withTargetsDir = require("@kingstinct/expo-apple-targets/build/config-plugin");
const { createRunOncePlugin, withInfoPlist } = require("expo/config-plugins");

const withCopyTargetFolder = require("./config-plugin/withCopyTargetFolder");
const withEntitlementsPlugin = require("./config-plugin/withEntitlements");
const withXcodeSettings = require("./config-plugin/withXCodeSettings");
const pkg = require("./package.json");

const withAllXcodeSettings = (config, props) => {
  return withXcodeSettings(config, { appGroup: props.appGroup });
};

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string }>} */
const updateInfoPlist = (config, props) => {
  return withInfoPlist(config, (config) => {
    config.modResults.REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP =
      "$(REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP)";
    return config;
  });
};

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appleTeamId: string; match?: string; appGroup: string; copyToTargetFolder?: boolean }>} */
const withActivityMonitorExtensionPlugin = (config, props) => {
  if (!props || !props.appGroup || typeof props.appleTeamId !== "string") {
    throw Error(
      "'appGroup' and 'appleTeamId' props are required for react-native-device-activity config plugin",
    );
  }

  return withAllXcodeSettings(
    updateInfoPlist(
      withTargetsDir(
        withEntitlementsPlugin(withCopyTargetFolder(config, props), props),
        props,
      ),
      props,
    ),
    props,
  );
};

module.exports = createRunOncePlugin(
  withActivityMonitorExtensionPlugin,
  pkg.name,
  pkg.version,
);
