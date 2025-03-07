const { withEntitlementsPlist } = require("expo/config-plugins");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; }>} */
const withEntitlementsPlugin = (config, { appGroup }) =>
  withEntitlementsPlist(config, (config) => {
    // todo: make this configurable - but would requiring changes in both Swift code and the /target/Info.plist to make sense
    config.modResults["com.apple.security.application-groups"] = [
      ...(config.modResults["com.apple.security.application-groups"]?.filter(
        (group) => group !== appGroup,
      ) ?? []),
      appGroup,
    ];
    config.modResults["com.apple.developer.family-controls"] = true;

    return config;
  });

module.exports = withEntitlementsPlugin;
