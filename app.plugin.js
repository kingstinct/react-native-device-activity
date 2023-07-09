/** @type {import('@kingstinct/expo-apple-targets/target-plugin/config').Config} */
const withTargetPlugin =
  require("@kingstinct/expo-apple-targets/target-plugin/build").default;
const { createRunOncePlugin } = require("expo/config-plugins");
const fs = require("fs");

const pkg = require("./package.json");

/** @type {import('@expo/config-plugins').ConfigPlugin} */
const withCopyTargetFolder = (config) => {
  const projectRoot = config._internal.projectRoot;
  // eslint-disable-next-line no-undef
  const packageTargetFolderPath = __dirname + "/targets";
  const projectTargetFolderPath = projectRoot + "/targets";

  if (!fs.existsSync(projectTargetFolderPath)) {
    fs.mkdirSync(projectTargetFolderPath);
  }

  fs.cpSync(packageTargetFolderPath, projectTargetFolderPath, {
    recursive: true,
  });

  return config;
};

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appleTeamId: string; match?: string; }>} */
const withActivityMonitorExtensionPlugin = (config, props) => {
  return withCopyTargetFolder(withTargetPlugin(config, props));
};

module.exports = createRunOncePlugin(
  withActivityMonitorExtensionPlugin,
  pkg.name,
  pkg.version
);
