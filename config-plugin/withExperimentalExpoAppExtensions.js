const { targets } = require("./withTargetEntitlements");

/** @type {import('@expo/config-plugins').ConfigPlugin<{ appGroup: string; }>} */
const withExpoExperimentalAppExtensionFlags = (config, props) => {
  config.extra = {
    ...config.extra,
    eas: {
      ...config.extra?.eas,
      build: {
        ...config.extra?.eas?.build,
        experimental: {
          ...config.extra?.eas?.build?.experimental,
          ios: {
            ...config.extra?.eas?.build?.experimental?.ios,
            appExtensions: targets.map((targetName) => {
              return {
                targetName,
                bundleIdentifier:
                  config.ios.bundleIdentifier + "." + targetName,
                entitlements: {
                  "com.apple.developer.family-controls": true,
                  "com.apple.security.application-groups": [props.appGroup],
                },
              };
            }),
          },
        },
      },
    },
  };

  return config;
};

module.exports = withExpoExperimentalAppExtensionFlags;
