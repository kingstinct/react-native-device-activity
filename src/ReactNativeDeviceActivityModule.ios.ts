import { requireNativeModule } from "expo-modules-core";

import { appGroupName } from "./AppGroup";

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
const deviceActivityModule = requireNativeModule("ReactNativeDeviceActivity");

deviceActivityModule.setAppGroup(appGroupName);

export default deviceActivityModule;
