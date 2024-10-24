const fs = require("fs");

/** @type {import('@expo/config-plugins').ConfigPlugin} */
const withCopyTargetFolder = (config) => {
  const projectRoot = config._internal.projectRoot;
  // eslint-disable-next-line no-undef
  const packageTargetFolderPath = __dirname + "/../targets";
  const projectTargetFolderPath = projectRoot + "/targets";

  if (!fs.existsSync(projectTargetFolderPath)) {
    fs.mkdirSync(projectTargetFolderPath);
  }

  fs.cpSync(packageTargetFolderPath, projectTargetFolderPath, {
    recursive: true,
  });

  return config;
};

module.exports = withCopyTargetFolder;
