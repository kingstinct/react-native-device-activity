import { NativeModule, requireOptionalNativeModule } from "expo-modules-core";

import { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";
import { OnAuthorizationStatusChange } from "./ReactNativeDeviceActivityModule";

const deviceActivityModule =
  requireOptionalNativeModule<ReactNativeDeviceActivityNativeModule>(
    "ReactNativeDeviceActivity",
  ) as ReactNativeDeviceActivityNativeModule &
    typeof NativeModule<{
      onAuthorizationStatusChange: OnAuthorizationStatusChange;
    }>;

export default deviceActivityModule;
