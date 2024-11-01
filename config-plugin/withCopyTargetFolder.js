const { default: plist } = require("@expo/plist");
const fs = require("fs");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; }>} */
const withCopyTargetFolder = (config, { appGroup }) => {
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

  // find all entitlements files in the projectTargetFolderPath
  const entitlementsFiles = fs
    .readdirSync(projectTargetFolderPath, { recursive: true })
    .filter((file) => file.endsWith(".entitlements"));

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

  const swiftFiles = fs
    .readdirSync(projectTargetFolderPath, { recursive: true })
    .filter((file) => file.endsWith(".swift"));

  for (const swiftFile of swiftFiles) {
    const swiftFilePath = projectTargetFolderPath + "/" + swiftFile;
    const swiftFileContents = fs.readFileSync(swiftFilePath, "utf8");

    const modifiedSwiftFileContents = swiftFileContents.replace(
      "group.ActivityMonitor",
      appGroup,
    );

    fs.writeFileSync(swiftFilePath, modifiedSwiftFileContents);
  }

  return config;
};

module.exports = withCopyTargetFolder;
