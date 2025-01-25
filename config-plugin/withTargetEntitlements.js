const { default: plist } = require("@expo/plist");
const fs = require("fs");

const targets = [
  "ActivityMonitorExtension",
  "ShieldConfiguration",
  "ShieldAction",
];

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; }>} */
const withTargetEntitlements = (config, { appGroup }) => {
  const projectRoot = config._internal.projectRoot;
  // eslint-disable-next-line no-undef
  const projectTargetFolderPath = projectRoot + "/targets";

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

module.exports = withTargetEntitlements;
