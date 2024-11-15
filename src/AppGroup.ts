import Constants from "expo-constants";

const pluginConfig = Constants.expoConfig?.plugins?.find(
  (p) => p[0] === "react-native-device-activity" || p[0] === "../app.plugin.js",
);

export const appGroupName = pluginConfig?.[1]?.appGroup as string;

if (!appGroupName) {
  console.error(
    "appGroup is not set for react-native-device-activity config plugin",
  );
  throw new Error(
    "appGroup is not set for react-native-device-activity config plugin",
  );
}
