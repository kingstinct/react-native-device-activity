const { withEntitlementsPlist } = require("expo/config-plugins");

/**
 * @type {ConfigPlugin}
 */
const withEntitlementsPlugin = (config) =>
  withEntitlementsPlist(config, (config) => {
    // todo: make this configurable - but would requiring changes in both Swift code and the /target/Info.plist to make sense
    config.modResults["com.apple.security.application-groups"] =
      "group.ActivityMonitor";
    config.modResults["com.apple.developer.family-controls"] = true;

    return config;
  });

module.exports = withEntitlementsPlugin;
