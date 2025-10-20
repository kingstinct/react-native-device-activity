import { EventEmitter, EventSubscription } from "expo-modules-core";
import { useCallback, useEffect, useState } from "react";
import { Platform } from "react-native";

import DeviceActivitySelectionView from "./DeviceActivitySelectionView";
import DeviceActivitySelectionViewPersisted from "./DeviceActivitySelectionViewPersisted";
import {
  Action,
  ActivitySelectionInput,
  ActivitySelectionInputWithBlocks,
  ActivitySelectionMetadata,
  ActivitySelectionWithMetadata,
  AuthorizationStatus,
  AuthorizationStatusType,
  CallbackEventName,
  CallbackName,
  DeviceActivityEvent,
  DeviceActivityEventRaw,
  DeviceActivityMonitorEventPayload,
  DeviceActivitySchedule,
  DeviceActivitySelectionViewPersistedProps,
  DeviceActivitySelectionViewProps,
  EventListenerMap,
  EventParsed,
  FamilyActivitySelection,
  OnDeviceActivityDetectedListener,
  SetOperationOptions,
  ShieldActions,
  ShieldConfiguration,
  OnAuthorizationStatusChange,
} from "./ReactNativeDeviceActivity.types";
import ReactNativeDeviceActivityModule from "./ReactNativeDeviceActivityModule";

export async function requestAuthorization(
  forIndividualOrChild: "individual" | "child" = "individual",
) {
  try {
    await ReactNativeDeviceActivityModule?.requestAuthorization(
      forIndividualOrChild,
    );
  } catch (error) {
    // Re-throw the error so it can be properly handled by the caller
    throw error;
  }
}

export async function revokeAuthorization(): Promise<AuthorizationStatusType> {
  await ReactNativeDeviceActivityModule?.revokeAuthorization();
  return getAuthorizationStatus();
}

export function getEvents(
  onlyEventsForActivityWithName?: string,
): EventParsed[] {
  const events =
    ReactNativeDeviceActivityModule?.getEvents(onlyEventsForActivityWithName) ??
    {};

  const eventsParsed = Object.keys(events).map((key) => {
    const [, activityName, callbackName, eventName] = key.split("_");
    const lastCalledAtVal = events[key] ?? 0;
    return {
      activityName,
      callbackName: callbackName as CallbackEventName,
      eventName,
      lastCalledAt: new Date(lastCalledAtVal),
    } as EventParsed;
  });

  return eventsParsed.sort(
    (a, b) => a.lastCalledAt.getTime() - b.lastCalledAt.getTime(),
  );
}

export function userDefaultsSet(key: string, value: any) {
  return ReactNativeDeviceActivityModule?.userDefaultsSet({ key, value });
}

export function userDefaultsGet<T>(key: string): T | undefined {
  return ReactNativeDeviceActivityModule?.userDefaultsGet(key) as T | undefined;
}

export function userDefaultsRemove(key: string) {
  return ReactNativeDeviceActivityModule?.userDefaultsRemove(key);
}

export function userDefaultsAll(): Record<string, any> {
  return ReactNativeDeviceActivityModule?.userDefaultsAll() ?? {};
}

export function userDefaultsClear() {
  return ReactNativeDeviceActivityModule?.userDefaultsClear();
}

export function userDefaultsClearWithPrefix(prefix: string) {
  return ReactNativeDeviceActivityModule?.userDefaultsClearWithPrefix(prefix);
}

export function clearWhitelistAndUpdateBlock(triggeredBy?: string) {
  return ReactNativeDeviceActivityModule?.clearWhitelistAndUpdateBlock(
    triggeredBy,
  );
}

export const clearWhitelist = () => {
  return ReactNativeDeviceActivityModule?.clearWhitelist();
};

const handleScreenTimeError = (error: any) => {
  if (
    error?.message?.includes("TryingToBlockSelectionWhenBlockModeIsEnabled")
  ) {
    console.warn(
      "Blocking a selection when blockAllMode is enabled will not have any effect",
    );
  } else if (
    error?.message?.includes("WhitelistSelectionWithoutEntireCategoryError")
  ) {
    console.warn(
      "A selection without includeEntireCategory means categories might not be correctly whitelisted, (not supported before iOS 15.2)",
    );
  } else {
    console.warn(error.message);
  }
};

export const refreshManagedSettingsStore = () => {
  return ReactNativeDeviceActivityModule?.refreshManagedSettingsStore();
};

export const clearAllManagedSettingsStoreSettings = () => {
  return ReactNativeDeviceActivityModule?.clearAllManagedSettingsStoreSettings();
};

export function addSelectionToWhitelistAndUpdateBlock(
  selection: ActivitySelectionInput,
  triggeredBy?: string,
) {
  try {
    return ReactNativeDeviceActivityModule?.addSelectionToWhitelistAndUpdateBlock(
      selection,
      triggeredBy,
    );
  } catch (error) {
    handleScreenTimeError(error);
  }
}

export function removeSelectionFromWhitelistAndUpdateBlock(
  selection: ActivitySelectionInput,
  triggeredBy?: string,
) {
  try {
    return ReactNativeDeviceActivityModule?.removeSelectionFromWhitelistAndUpdateBlock(
      selection,
      triggeredBy,
    );
  } catch (error) {
    handleScreenTimeError(error);
  }
}
function convertDeviceActivityEvents(
  events: DeviceActivityEvent[],
): [DeviceActivityEventRaw[], FamilyActivitySelection[]] {
  const uniqueSelections: FamilyActivitySelection[] = [];

  const convertedEvents = events.map((event) => {
    const selectionIndex = uniqueSelections.indexOf(
      event.familyActivitySelection,
    );

    const wasFound = selectionIndex !== -1;

    if (!wasFound) {
      uniqueSelections.push(event.familyActivitySelection);
    }

    const familyActivitySelectionIndex = !wasFound
      ? uniqueSelections.length - 1
      : selectionIndex;

    const convertedEvent: DeviceActivityEventRaw = {
      ...event,
      familyActivitySelectionIndex,
    };

    return convertedEvent;
  });

  return [convertedEvents, uniqueSelections];
}

export async function startMonitoring(
  activityName: string,
  deviceActivitySchedule: DeviceActivitySchedule,
  deviceActivityEvents: DeviceActivityEvent[],
): Promise<void> {
  const [deviceActivityEventsRaw, uniqueSelections] =
    convertDeviceActivityEvents(deviceActivityEvents);

  return ReactNativeDeviceActivityModule?.startMonitoring(
    activityName,
    deviceActivitySchedule,
    deviceActivityEventsRaw,
    uniqueSelections,
  );
}

export const reloadDeviceActivityCenter = () => {
  return ReactNativeDeviceActivityModule?.reloadDeviceActivityCenter();
};

export const intersection = (
  familyActivitySelection: ActivitySelectionInputWithBlocks,
  familyActivitySelection2: ActivitySelectionInputWithBlocks,
  options?: SetOperationOptions,
): ActivitySelectionWithMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.intersection(
    familyActivitySelection,
    familyActivitySelection2,
    options ?? {},
  );
};

export const union = (
  familyActivitySelection: ActivitySelectionInputWithBlocks,
  familyActivitySelection2: ActivitySelectionInputWithBlocks,
  options?: SetOperationOptions,
): ActivitySelectionWithMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.union(
    familyActivitySelection,
    familyActivitySelection2,
    options ?? {},
  );
};

export const difference = (
  familyActivitySelection: ActivitySelectionInputWithBlocks,
  familyActivitySelection2: ActivitySelectionInputWithBlocks,
  options?: SetOperationOptions,
): ActivitySelectionWithMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.difference(
    familyActivitySelection,
    familyActivitySelection2,
    options ?? {},
  );
};

export const symmetricDifference = (
  familyActivitySelection: ActivitySelectionInputWithBlocks,
  familyActivitySelection2: ActivitySelectionInputWithBlocks,
  options?: SetOperationOptions,
): ActivitySelectionWithMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.symmetricDifference(
    familyActivitySelection,
    familyActivitySelection2,
    options ?? {},
  );
};

export const activitySelectionMetadata = (
  activitySelection: ActivitySelectionInputWithBlocks,
): ActivitySelectionMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.activitySelectionMetadata(
    activitySelection,
  );
};

export const activitySelectionWithMetadata = (
  activitySelection: ActivitySelectionInputWithBlocks,
): ActivitySelectionWithMetadata | undefined => {
  return ReactNativeDeviceActivityModule?.activitySelectionWithMetadata(
    activitySelection,
  );
};

export const configureActions = ({
  activityName,
  callbackName,
  actions,
  eventName,
}: {
  activityName: string;
  callbackName: CallbackName;
  actions: Action[];
  eventName?: string;
}) => {
  const key = eventName
    ? `actions_for_${activityName}_${callbackName}_${eventName}`
    : `actions_for_${activityName}_${callbackName}`;

  userDefaultsSet(
    key,
    actions.map((action) => ({
      ...action,
      skipIfLargerEventRecordedAfter:
        action.skipIfLargerEventRecordedAfter?.getTime(),
      skipIfAlreadyTriggeredAfter:
        action.skipIfAlreadyTriggeredAfter?.getTime(),
      neverTriggerBefore: action.neverTriggerBefore?.getTime(),
      skipIfAlreadyTriggeredBefore:
        action.skipIfAlreadyTriggeredBefore?.getTime(),
      skipIfAlreadyTriggeredBetweenFromDate:
        action.skipIfAlreadyTriggeredBetween?.fromDate?.getTime(),
      skipIfAlreadyTriggeredBetweenToDate:
        action.skipIfAlreadyTriggeredBetween?.toDate?.getTime(),
    })),
  );
};

export const cleanUpAfterActivity = (activityName: string) => {
  ReactNativeDeviceActivityModule?.userDefaultsClearWithPrefix(
    `actions_for_${activityName}`,
  );
  ReactNativeDeviceActivityModule?.userDefaultsClearWithPrefix(
    `events_${activityName}`,
  );
};

export const setFamilyActivitySelectionId = ({
  id,
  familyActivitySelection,
}: {
  id: string;
  familyActivitySelection: string;
}) => {
  const previousValue =
    (ReactNativeDeviceActivityModule?.userDefaultsGet(
      "familyActivitySelectionIds",
    ) as Record<string, string>) ?? {};

  userDefaultsSet("familyActivitySelectionIds", {
    ...previousValue,
    [id]: familyActivitySelection,
  });
};

export const getFamilyActivitySelectionId = (id: string) => {
  const previousValue =
    (ReactNativeDeviceActivityModule?.userDefaultsGet(
      "familyActivitySelectionIds",
    ) as Record<string, string>) ?? {};

  return previousValue[id];
};

export function getAppGroupFileDirectory(): string {
  return ReactNativeDeviceActivityModule?.getAppGroupFileDirectory() ?? "";
}

export function onDeviceActivityDetected(
  listener: OnDeviceActivityDetectedListener,
) {
  if (!emitter) {
    return { remove: () => {} };
  }

  const handler = emitter?.addListener("onDeviceActivityDetected", listener);

  return handler;
}

export const useDeviceActivities = () => {
  const [activities, setActivities] = useState<string[]>([]);

  useEffect(() => {
    // this one seems more stable
    const sub = onDeviceActivityMonitorEvent((event) => {
      if (event.callbackName === "intervalDidStart") {
        setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);
      }
    });
    const subscription = onDeviceActivityDetected((event) => {
      setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);
    });

    setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);

    return () => {
      subscription.remove();
      sub.remove();
    };
  }, []);

  return activities;
};

export function stopMonitoring(activityNames?: string[]): void {
  return ReactNativeDeviceActivityModule?.stopMonitoring(activityNames);
}

export function getActivities(): string[] {
  return ReactNativeDeviceActivityModule?.activities() ?? [];
}

export function isShieldActive(): boolean {
  return ReactNativeDeviceActivityModule?.isShieldActive() ?? false;
}

export function moveFile(
  sourceUri: string,
  destinationUri: string,
  overwrite: boolean = false,
) {
  return ReactNativeDeviceActivityModule?.moveFile(
    sourceUri,
    destinationUri,
    overwrite,
  );
}

export function copyFile(
  sourceUri: string,
  destinationUri: string,
  overwrite: boolean = false,
) {
  return ReactNativeDeviceActivityModule?.copyFile(
    sourceUri,
    destinationUri,
    overwrite,
  );
}

export function blockSelection(
  activitySelection: ActivitySelectionInput,
  triggeredBy?: string,
): void {
  try {
    return ReactNativeDeviceActivityModule?.blockSelection(
      activitySelection,
      triggeredBy,
    );
  } catch (error) {
    handleScreenTimeError(error);
  }
}

export function enableBlockAllMode(triggeredBy?: string): void {
  return ReactNativeDeviceActivityModule?.enableBlockAllMode(triggeredBy);
}

export function disableBlockAllMode(triggeredBy?: string): void {
  return ReactNativeDeviceActivityModule?.disableBlockAllMode(triggeredBy);
}

export function resetBlocks(triggeredBy?: string): void {
  return ReactNativeDeviceActivityModule?.resetBlocks(triggeredBy);
}

export function unblockSelection(
  familyActivitySelection: ActivitySelectionInput,
  triggeredBy?: string,
): void {
  try {
    return ReactNativeDeviceActivityModule?.unblockSelection(
      familyActivitySelection,
      triggeredBy,
    );
  } catch (error) {
    handleScreenTimeError(error);
  }
}

export function getAuthorizationStatus(): AuthorizationStatusType {
  return (
    ReactNativeDeviceActivityModule?.authorizationStatus() ??
    AuthorizationStatus.notDetermined
  );
}

const emitter = ReactNativeDeviceActivityModule
  ? new EventEmitter<EventListenerMap>(ReactNativeDeviceActivityModule)
  : undefined;

export const useActivities = () => {
  const [activities, setActivities] = useState<string[]>([]);

  useEffect(() => {
    const subscription = onDeviceActivityDetected(() => {
      setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);
    });

    setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);

    return () => {
      subscription.remove();
    };
  }, []);

  const refresh = useCallback(() => {
    setActivities(ReactNativeDeviceActivityModule?.activities() ?? []);
  }, []);

  return [activities, refresh] as const;
};

const DEFAULT_MAX_ATTEMPTS = 10;
const DEFAULT_POLL_INTERVAL_MS = 250;

const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const pollAuthorizationStatus = async ({
  abortController,
  pollIntervalMs = DEFAULT_POLL_INTERVAL_MS,
  maxAttempts = DEFAULT_MAX_ATTEMPTS,
}: {
  abortController?: AbortController;
  pollIntervalMs?: number;
  maxAttempts?: number;
} = {}): Promise<AuthorizationStatusType> => {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const status = getAuthorizationStatus();

    if (
      status !== AuthorizationStatus.notDetermined ||
      abortController?.signal.aborted
    ) {
      return status;
    }

    await wait(pollIntervalMs);
  }

  // return final status even if maxAttempts reached
  return getAuthorizationStatus();
};

export const useAuthorizationStatus = () => {
  const [authorizationStatus, setAuthorizationStatus] =
    useState<AuthorizationStatusType>(AuthorizationStatus.notDetermined);

  useEffect(() => {
    const subscription = onAuthorizationStatusChange((event) => {
      setAuthorizationStatus(event.authorizationStatus);
    });

    setAuthorizationStatus(getAuthorizationStatus());

    return () => {
      subscription.remove();
    };
  }, []);

  return authorizationStatus;
};

export function onAuthorizationStatusChange(
  listener: OnAuthorizationStatusChange,
): EventSubscription {
  if (!emitter) {
    return { remove: () => {} };
  }

  return emitter.addListener("onAuthorizationStatusChange", listener);
}

export function onDeviceActivityMonitorEvent(
  listener: (event: DeviceActivityMonitorEventPayload) => void,
): EventSubscription {
  if (!emitter) {
    return { remove: () => {} };
  }
  return emitter.addListener("onDeviceActivityMonitorEvent", listener);
}

export const SHIELD_ACTIONS_KEY = "shieldActions";
export const SHIELD_CONFIGURATION_KEY = "shieldConfiguration";

export function updateShield(
  shieldConfiguration: ShieldConfiguration,
  shieldActions: ShieldActions,
  triggeredBy = "updateShieldCalledManually",
) {
  userDefaultsSet(SHIELD_CONFIGURATION_KEY, {
    ...shieldConfiguration,
    triggeredBy,
    updatedAt: new Date().toISOString(),
  });
  userDefaultsSet(SHIELD_ACTIONS_KEY, {
    ...shieldActions,
    triggeredBy,
    updatedAt: new Date().toISOString(),
  });
}

export function useShieldWithId(shieldId: string = "default") {
  const shieldConfiguration = userDefaultsGet(
    `shieldConfiguration_${shieldId}`,
  ) as ShieldConfiguration | undefined;
  const shieldActions = userDefaultsGet(`shieldActions_${shieldId}`) as
    | ShieldActions
    | undefined;

  if (shieldConfiguration && shieldActions) {
    updateShield(shieldConfiguration, shieldActions);
  }
}

export function updateShieldWithId(
  shieldConfiguration: ShieldConfiguration,
  shieldActions: ShieldActions,
  shieldId: string = "default",
) {
  userDefaultsSet(`shieldConfiguration_${shieldId}`, shieldConfiguration);
  userDefaultsSet(`shieldActions_${shieldId}`, shieldActions);
}

export function isEqual(
  a: ActivitySelectionInputWithBlocks,
  b: ActivitySelectionInputWithBlocks,
) {
  const symmetricDifference =
    ReactNativeDeviceActivityModule?.symmetricDifference(a, b, {
      stripToken: true,
    });

  return (
    symmetricDifference?.applicationCount === 0 &&
    symmetricDifference?.categoryCount === 0 &&
    symmetricDifference?.webDomainCount === 0
  );
}

export function isSubsetOf(
  subset: ActivitySelectionInputWithBlocks,
  superset: ActivitySelectionInputWithBlocks,
) {
  const metadata =
    ReactNativeDeviceActivityModule?.activitySelectionMetadata(subset);

  const intersection = ReactNativeDeviceActivityModule?.intersection(
    subset,
    superset,
    { stripToken: true },
  );

  return (
    intersection?.applicationCount === metadata?.applicationCount &&
    intersection?.categoryCount === metadata?.categoryCount &&
    intersection?.webDomainCount === metadata?.webDomainCount
  );
}

export function isAvailable(): boolean {
  return (
    Platform.OS === "ios" &&
    parseInt(Platform.Version, 10) >= 15 &&
    !!ReactNativeDeviceActivityModule
  );
}

export { DeviceActivitySelectionView, DeviceActivitySelectionViewPersisted };

export type {
  DeviceActivitySelectionViewProps as ReactNativeDeviceActivityViewProps,
  DeviceActivitySelectionViewPersistedProps as ReactNativeDeviceActivityViewPersistedProps,
};

export * from "./ReactNativeDeviceActivity.types";
