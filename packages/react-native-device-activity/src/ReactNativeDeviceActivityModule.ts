import { ProxyNativeModule } from "expo-modules-core";

import type { ReactNativeDeviceActivityNativeModule } from "./ReactNativeDeviceActivity.types";

const warnText = "[react-native-device-activity] Only available on iOS";

const warnFn = () => {
  console.warn(warnText);
  return Promise.resolve();
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
    includeEntireCategory: false,
  };
};

const warnFnActivitySelectionMetadata = () => {
  console.warn(warnText);

  return {
    applicationCount: 0,
    categoryCount: 0,
    webDomainCount: 0,
    includeEntireCategory: false,
  };
};

const mockModule:
  | (ReactNativeDeviceActivityNativeModule & ProxyNativeModule)
  | null = {
  isAvailable: () => false,
  requestAuthorization: warnFn,
  blockSelection: warnFn,
  userDefaultsAll: warnFn,
  userDefaultsGet: warnFn,
  userDefaultsRemove: warnFn,
  userDefaultsSet: warnFn,
  userDefaultsClear: warnFn,
  activitySelectionWithMetadata: warnFnActivitySelectionWithMetadata,
  activitySelectionMetadata: warnFnActivitySelectionMetadata,
  intersection: warnFnActivitySelectionWithMetadata,
  union: warnFnActivitySelectionWithMetadata,
  difference: warnFnActivitySelectionWithMetadata,
  symmetricDifference: warnFnActivitySelectionWithMetadata,
  addSelectionToWhitelistAndUpdateBlock: warnFn,
  clearAllManagedSettingsStoreSettings: warnFn,
  clearWhitelistAndUpdateBlock: warnFn,
  convertToIncludeCategories: warnFnActivitySelectionWithMetadata,
  refreshManagedSettingsStore: warnFn,
  removeSelectionFromWhitelistAndUpdateBlock: warnFn,
  renameActivitySelection: warnFn,
  clearBlocklistAndUpdateBlock: warnFn,
  clearWhitelist: warnFn,
  unblockSelection: warnFn,
  revokeAuthorization: warnFn,
  isShieldActive: warnFnBoolean,
  getAppGroupFileDirectory: warnFn,
  doesSelectionHaveOverlap: warnFnBoolean,
  updateShieldConfiguration: warnFn,
  unblockApps: warnFn,
  enableBlockAllMode: warnFn,
  disableBlockAllMode: warnFn,
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
