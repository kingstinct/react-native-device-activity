import { ProxyNativeModule } from "expo-modules-core";

import type { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const warnText = "[react-native-device-activity] Only available on iOS";

const warnFn = () => {
  console.warn(warnText);
};

const mockModule: ReactNativeDeviceActivityNativeModule & ProxyNativeModule = {
  requestAuthorization: warnFn,
  getEvents: () => {
    console.warn(warnText);
    return {};
  },
  startMonitoring: warnFn,
  stopMonitoring: warnFn,
  addListener: warnFn,
  removeListeners: warnFn,
};

export default mockModule;
