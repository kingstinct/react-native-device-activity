import { NativeModule } from "expo-modules-core/types";

import {
  AuthorizationStatusType,
  ReactNativeDeviceActivityNativeModule,
} from "./ReactNativeDeviceActivity.types";

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

const warnFnAddListener = () => {
  console.warn(warnText);
  return { remove: () => {} };
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

export type OnAuthorizationStatusChange = ({
  authorizationStatus,
}: {
  authorizationStatus: AuthorizationStatusType;
}) => void;

const mockModule:
  | (ReactNativeDeviceActivityNativeModule &
      NativeModule<{
        onAuthorizationStatusChange: OnAuthorizationStatusChange;
      }>)
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
  resetBlocks: warnFn,
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
  removeListeners: warnFn,
  removeAllListeners: warnFn,
  emit: warnFn,
  removeListener: warnFn,
  stopObserving: warnFn,
  listenerCount: warnFnNumber,
  addListener: warnFnAddListener,
};

export default mockModule;
