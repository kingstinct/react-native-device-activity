/** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').Config} */
const withTargetsDir = require("@kingstinct/expo-apple-targets/build/config-plugin");
const { createRunOncePlugin } = require("expo/config-plugins");

const withCopyTargetFolder = require("./config-plugin/withCopyTargetFolder");
const withEntitlementsPlugin = require("./config-plugin/withEntitlements");
const withInfoPlistAppGroup = require("./config-plugin/withInfoPlistAppGroup");
const withXcodeSettings = require("./config-plugin/withXCodeSettings");
const pkg = require("../../package.json");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appleTeamId?: string; match?: string; appGroup: string; copyToTargetFolder?: boolean }>} */
const withActivityMonitorExtensionPlugin = (config, props) => {
  if (!props || !props.appGroup) {
    throw Error(
      "'appGroup' is required for react-native-device-activity config plugin",
    );
  }

  return withXcodeSettings(
    withInfoPlistAppGroup(
      withTargetsDir(
        withEntitlementsPlugin(withCopyTargetFolder(config, props), props),
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
