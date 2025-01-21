import { EventEmitter, Subscription } from "expo-modules-core";
import { useCallback, useEffect, useState } from "react";
import { Platform } from "react-native";

import DeviceActivitySelectionView from "./DeviceActivitySelectionView";
import {
  Action,
  AuthorizationStatus,
  AuthorizationStatusType,
  CallbackEventName,
  CallbackName,
  DeviceActivityEvent,
  DeviceActivityEventRaw,
  DeviceActivityMonitorEventPayload,
  DeviceActivitySchedule,
  DeviceActivitySelectionViewProps,
  EventParsed,
  FamilyActivitySelection,
  ShieldActions,
  ShieldConfiguration,
} from "./ReactNativeDeviceActivity.types";
import ReactNativeDeviceActivityModule from "./ReactNativeDeviceActivityModule";

export async function requestAuthorization(
  forIndividualOrChild: "individual" | "child" = "individual",
): Promise<AuthorizationStatusType> {
  try {
    await ReactNativeDeviceActivityModule?.requestAuthorization(
      forIndividualOrChild,
    );
  } catch (error) {
    // seems like we get a promise rejection if the user denies the authorization, but we can still request again
    console.error(error);
  }
  return getAuthorizationStatus();
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

  userDefaultsSet(key, actions);
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
  listener: (event: { activityName: string }) => void,
) {
  if (!emitter) {
    return { remove: () => {} };
  }

  const handler = emitter?.addListener<{ activityName: string }>(
    "onDeviceActivityDetected",
    listener,
  );

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

export function isShieldActiveWithSelection(
  familyActivitySelectionStr: string,
): boolean {
  return (
    ReactNativeDeviceActivityModule?.isShieldActiveWithSelection(
      familyActivitySelectionStr,
    ) ?? false
  );
}

export function blockApps(
  familyActivitySelectionStr?: string,
): PromiseLike<void> | void {
  return ReactNativeDeviceActivityModule?.blockApps(familyActivitySelectionStr);
}

export function unblockApps(): PromiseLike<void> | void {
  return ReactNativeDeviceActivityModule?.unblockApps();
}

export function getAuthorizationStatus(): AuthorizationStatusType {
  return (
    ReactNativeDeviceActivityModule?.authorizationStatus() ??
    AuthorizationStatus.notDetermined
  );
}

const emitter = ReactNativeDeviceActivityModule
  ? new EventEmitter(ReactNativeDeviceActivityModule)
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
  listener: (event: { authorizationStatus: AuthorizationStatusType }) => void,
): Subscription {
  if (!emitter) {
    return { remove: () => {} };
  }

  return emitter.addListener<{ authorizationStatus: AuthorizationStatusType }>(
    "onAuthorizationStatusChange",
    listener,
  );
}

export function onDeviceActivityMonitorEvent(
  listener: (event: DeviceActivityMonitorEventPayload) => void,
): Subscription {
  if (!emitter) {
    return { remove: () => {} };
  }
  return emitter.addListener<DeviceActivityMonitorEventPayload>(
    "onDeviceActivityMonitorEvent",
    listener,
  );
}

export function updateShield(
  shieldConfiguration: ShieldConfiguration,
  shieldActions: ShieldActions,
) {
  userDefaultsSet(`shieldConfiguration`, shieldConfiguration);
  userDefaultsSet(`shieldActions`, shieldActions);
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

export function isAvailable(): boolean {
  return (
    Platform.OS === "ios" &&
    parseInt(Platform.Version, 10) >= 15 &&
    !!ReactNativeDeviceActivityModule
  );
}

export { DeviceActivitySelectionView };

export type { DeviceActivitySelectionViewProps as ReactNativeDeviceActivityViewProps };

export * from "./ReactNativeDeviceActivity.types";
