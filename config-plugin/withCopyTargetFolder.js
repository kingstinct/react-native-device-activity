const { default: plist } = require("@expo/plist");
const fs = require("fs");

const targets = [
  "ActivityMonitorExtension",
  "ShieldConfiguration",
  "ShieldAction",
];

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; copyToTargetFolder?: boolean }>} */
const withCopyTargetFolder = (
  config,
  { appGroup, copyToTargetFolder = true },
) => {
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

  // find all entitlements files in the projectTargetFolderPath
  const entitlementsFiles = fs
    .readdirSync(projectTargetFolderPath, { recursive: true })
    .filter(
      (file) =>
        targets.some((target) => file.startsWith(target)) &&
        file.endsWith(".entitlements"),
    );

  for (const entitlementsFile of entitlementsFiles) {
    const entitlementsFilePath =
      projectTargetFolderPath + "/" + entitlementsFile;

    const entitlementsFileContents = fs.readFileSync(
      entitlementsFilePath,
      "utf8",
    );

    const parsedEntitlements = plist.parse(entitlementsFileContents);

    if (parsedEntitlements["com.apple.security.application-groups"]) {
      parsedEntitlements["com.apple.security.application-groups"] = [appGroup];
    }

    const modifiedEntitlementsFileContents = plist.build(parsedEntitlements);

    fs.writeFileSync(entitlementsFilePath, modifiedEntitlementsFileContents);
  }

  return config;
};

module.exports = withCopyTargetFolder;
