import type { ExpoConfig } from "expo/config";

const APPLE_TEAM_ID = process.env.RNDA_APPLE_TEAM_ID ?? "34SE8X7Q58";
const APP_GROUP = process.env.RNDA_APP_GROUP ?? "group.ActivityMonitor";
const IOS_BUNDLE_ID =
  process.env.RNDA_IOS_BUNDLE_ID ?? "expo.modules.deviceactivity.example";
const ANDROID_PACKAGE =
  process.env.RNDA_ANDROID_PACKAGE ?? "expo.modules.deviceactivity.example";

const appExtensions = [
  {
    targetName: "ActivityMonitorExtension",
    bundleIdentifier: `${IOS_BUNDLE_ID}.ActivityMonitorExtension`,
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [APP_GROUP],
    },
  },
  {
    targetName: "ShieldConfiguration",
    bundleIdentifier: `${IOS_BUNDLE_ID}.ShieldConfiguration`,
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [APP_GROUP],
    },
  },
  {
    targetName: "ShieldAction",
    bundleIdentifier: `${IOS_BUNDLE_ID}.ShieldAction`,
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [APP_GROUP],
    },
  },
] as const;

const config: ExpoConfig = {
  name: "react-native-device-activity-example",
  slug: "react-native-device-activity-example",
  version: "1.0.0",
  scheme: "device-activity",
  orientation: "portrait",
  icon: "./assets/icon.png",
  platforms: ["ios"],
  userInterfaceStyle: "light",
  splash: {
    image: "./assets/splash.png",
    resizeMode: "contain",
    backgroundColor: "#ffffff",
  },
  ios: {
    appleTeamId: APPLE_TEAM_ID,
    supportsTablet: true,
    bundleIdentifier: IOS_BUNDLE_ID,
  },
  assetBundlePatterns: ["assets/*"],
  android: {
    package: ANDROID_PACKAGE,
  },
  web: {
    favicon: "./assets/favicon.png",
  },
  plugins: [
    [
      "expo-build-properties",
      {
        ios: {
          deploymentTarget: "15.1",
        },
      },
    ],
    [
      "expo-asset",
      {
        assets: ["./assets/kingstinct.png"],
      },
    ],
    [
      "react-native-device-activity",
      {
        appGroup: APP_GROUP,
        copyToTargetFolder: false,
      },
    ],
  ],
  extra: {
    eas: {
      build: {
        experimental: {
          ios: {
            appExtensions,
          },
        },
      },
    },
  },
};

export default config;
