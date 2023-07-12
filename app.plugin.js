/** @type {import('@kingstinct/expo-apple-targets/target-plugin/config').Config} */
const withTargetPlugin =
  require("@kingstinct/expo-apple-targets/target-plugin/build").default;
const { createRunOncePlugin } = require("expo/config-plugins");

const withCopyTargetFolder = require("./config-plugin/withCopyTargetFolder");
const withEntitlementsPlugin = require("./config-plugin/withEntitlements");
const pkg = require("./package.json");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appleTeamId: string; match?: string; }>} */
const withActivityMonitorExtensionPlugin = (config, props) => {
  return withTargetPlugin(
    withEntitlementsPlugin(withCopyTargetFolder(config)),
    props,
  );
};

module.exports = createRunOncePlugin(
  withActivityMonitorExtensionPlugin,
  pkg.name,
  pkg.version,
);
