import { ProxyNativeModule } from "expo-modules-core";

import type { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const warnText = "[react-native-device-activity] Only available on iOS";

const warnFn = () => {
  console.warn(warnText);
};

const warnFnArray = () => {
  console.warn(warnText);
  return [];
};

const warnFnNumber = () => {
  console.warn(warnText);
  return 0;
};

const mockModule: ReactNativeDeviceActivityNativeModule & ProxyNativeModule = {
  isAvailable: () => false,
  requestAuthorization: warnFn,
  revokeAuthorization: warnFn,
  activities: warnFnArray,
  authorizationStatus: warnFnNumber,
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
