import { requireNativeModule } from "expo-modules-core";

import { appGroupName } from "./AppGroup";
import { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const loadDeviceActivityModuleSafe = ():
  | ReactNativeDeviceActivityNativeModule
  | undefined => {
  try {
    // It loads the native module object from the JSI or falls back to
    // the bridge module (from NativeModulesProxy) if the remote debugger is on.
    const deviceActivityModule = requireNativeModule(
      "ReactNativeDeviceActivity",
    );
    return deviceActivityModule;
  } catch (error) {
    console.warn("Error loading ReactNativeDeviceActivity module", error);
    return undefined;
  }
};

const deviceActivityModule = loadDeviceActivityModuleSafe();

if (appGroupName) {
  deviceActivityModule?.setAppGroup(appGroupName);
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
