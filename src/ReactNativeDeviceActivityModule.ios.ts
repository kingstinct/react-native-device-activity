import Constants from "expo-constants";
import { requireNativeModule } from "expo-modules-core";

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
const deviceActivityModule = requireNativeModule("ReactNativeDeviceActivity");

// fetch appGroup from plugin config, so it's configurable from one single place
const pluginConfig = Constants.expoConfig?.plugins?.find(
  (p) => p[0] === "react-native-device-activity" || p[0] === "../app.plugin.js",
);

const appGroup = pluginConfig?.[1]?.appGroup;

if (!appGroup) {
  console.error(
    "appGroup is not set for react-native-device-activity config plugin",
  );
}

deviceActivityModule.setAppGroup(appGroup);

export default deviceActivityModule;
