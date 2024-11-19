/** @type {import('@kingstinct/expo-apple-targets/target-plugin/config').Config} */
const withTargetPlugin =
  require("@kingstinct/expo-apple-targets/target-plugin/build").default;
const { createRunOncePlugin } = require("expo/config-plugins");

const withCopyTargetFolder = require("./config-plugin/withCopyTargetFolder");
const withEntitlementsPlugin = require("./config-plugin/withEntitlements");
const pkg = require("./package.json");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appleTeamId: string; match?: string; appGroup: string; copyToTargetFolder?: boolean }>} */
const withActivityMonitorExtensionPlugin = (config, props) => {
  if (!props || !props.appGroup || typeof props.appleTeamId !== "string") {
    throw Error(
      "'appGroup' and 'appleTeamId' props are required for react-native-device-activity config plugin",
    );
  }

  return withTargetPlugin(
    withEntitlementsPlugin(withCopyTargetFolder(config, props), props),
    props,
  );
};

module.exports = createRunOncePlugin(
  withActivityMonitorExtensionPlugin,
  pkg.name,
  pkg.version,
);
