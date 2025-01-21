import { requireOptionalNativeModule } from "expo-modules-core";

import { appGroupName } from "./AppGroup";
import { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const deviceActivityModule =
  requireOptionalNativeModule<ReactNativeDeviceActivityNativeModule>(
    "ReactNativeDeviceActivity",
  );

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
