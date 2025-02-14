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

const warnFnNumber = <T extends number>() => {
  console.warn(warnText);
  return 0 as T;
};

const warnFnBoolean = () => {
  console.warn(warnText);
  return false;
};

const warnFnActivitySelectionWithMetadata = () => {
  console.warn(warnText);
  return {
    familyActivitySelection: null,
    applicationCount: 0,
    categoryCount: 0,
    webDomainCount: 0,
  };
};

const mockModule:
  | (ReactNativeDeviceActivityNativeModule & ProxyNativeModule)
  | null = {
  isAvailable: () => false,
  requestAuthorization: warnFn,
  userDefaultsAll: warnFn,
  userDefaultsGet: warnFn,
  userDefaultsRemove: warnFn,
  userDefaultsSet: warnFn,
  userDefaultsClear: warnFn,
  activitySelectionMetadata: warnFnActivitySelectionWithMetadata,
  intersection: warnFnActivitySelectionWithMetadata,
  union: warnFnActivitySelectionWithMetadata,
  difference: warnFnActivitySelectionWithMetadata,
  symmetricDifference: warnFnActivitySelectionWithMetadata,
  revokeAuthorization: warnFn,
  isShieldActive: warnFnBoolean,
  getAppGroupFileDirectory: warnFn,
  isShieldActiveWithSelection: warnFnBoolean,
  doesSelectionHaveOverlap: warnFnBoolean,
  updateShieldConfiguration: warnFn,
  unblockApps: warnFn,
  blockApps: warnFn,
  activities: warnFnArray,
  authorizationStatus: warnFnNumber,
  reloadDeviceActivityCenter: warnFn,
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
