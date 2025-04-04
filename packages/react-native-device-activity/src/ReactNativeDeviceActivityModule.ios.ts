import { requireOptionalNativeModule } from "expo-modules-core";

import { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const deviceActivityModule =
  requireOptionalNativeModule<ReactNativeDeviceActivityNativeModule>(
    "ReactNativeDeviceActivity",
  ) as ReactNativeDeviceActivityNativeModule;

export default deviceActivityModule;
