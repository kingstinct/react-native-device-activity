const fs = require("fs");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; copyToTargetFolder?: boolean }>} */
const withCopyTargetFolder = (config, { copyToTargetFolder = true }) => {
  if (!copyToTargetFolder) {
    return config;
  }

  const projectRoot = config._internal.projectRoot;
  // eslint-disable-next-line no-undef
  const packageTargetFolderPath = __dirname + "/../targets";
  const projectTargetFolderPath = projectRoot + "/targets";

  // eslint-disable-next-line no-undef
  const sharedFilePath = __dirname + "/../ios/Shared.swift";

  if (!fs.existsSync(projectTargetFolderPath)) {
    fs.mkdirSync(projectTargetFolderPath);
  }

  fs.cpSync(packageTargetFolderPath, projectTargetFolderPath, {
    recursive: true,
  });

  const nativeTargets = fs.readdirSync(packageTargetFolderPath, {
    withFileTypes: false,
  });

  for (const nativeTarget of nativeTargets) {
    const targetPath = projectTargetFolderPath + "/" + nativeTarget;
    // check if is directory
    if (fs.lstatSync(targetPath).isDirectory()) {
      fs.cpSync(sharedFilePath, targetPath + "/Shared.swift");
    }
  }

  return config;
};

module.exports = withCopyTargetFolder;
