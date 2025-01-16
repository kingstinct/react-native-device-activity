import { requireNativeModule } from "expo-modules-core";

import { appGroupName } from "./AppGroup";

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
const deviceActivityModule = requireNativeModule("ReactNativeDeviceActivity");

if (appGroupName) {
  deviceActivityModule.setAppGroup(appGroupName);
} else {
  const SKIP_APPGROUP_WARNING = process.env.SKIP_APPGROUP_WARNING
    ? JSON.parse(process.env.SKIP_APPGROUP_WARNING)
    : false;

  if (!SKIP_APPGROUP_WARNING) {
    console.warn(
      "appGroup is not set for react-native-device-activity config plugin",
    );
  }
}

export default deviceActivityModule;
