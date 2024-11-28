import {
  NativeModulesProxy,
  EventEmitter,
  Subscription,
} from "expo-modules-core";

// Import the native module. On web, it will be resolved to ReactNativeDeviceActivity.web.ts
// and on native platforms to ReactNativeDeviceActivity.ts
import { Platform } from "react-native";

import DeviceActivitySelectionView from "./DeviceActivitySelectionView";
import {
  Action,
  AuthorizationStatus,
  CallbackEventName,
  CallbackName,
  DeviceActivityEvent,
  DeviceActivityEventRaw,
  DeviceActivityMonitorEventPayload,
  DeviceActivitySchedule,
  DeviceActivitySelectionViewProps,
  EventParsed,
  FamilyActivitySelection,
  ShieldConfiguration,
} from "./ReactNativeDeviceActivity.types";
import ReactNativeDeviceActivityModule from "./ReactNativeDeviceActivityModule";

export async function requestAuthorization(): Promise<AuthorizationStatus> {
  try {
    await ReactNativeDeviceActivityModule.requestAuthorization();
  } catch (error) {
    // seems like we get a promise rejection if the user denies the authorization, but we can still request again
    console.error(error);
  }
  return getAuthorizationStatus();
}

export async function revokeAuthorization(): Promise<AuthorizationStatus> {
  await ReactNativeDeviceActivityModule.revokeAuthorization();
  return getAuthorizationStatus();
}

export function getEvents(
  onlyEventsForActivityWithName?: string,
): EventParsed[] {
  const events = ReactNativeDeviceActivityModule.getEvents(
    onlyEventsForActivityWithName,
  );

  const eventsParsed = Object.keys(events).map((key) => {
    const [, activityName, callbackName, eventName] = key.split("#");
    return {
      activityName,
      callbackName: callbackName as CallbackEventName,
      eventName,
      lastCalledAt: new Date(events[key]),
    };
  });

  return eventsParsed.sort(
    (a, b) => a.lastCalledAt.getTime() - b.lastCalledAt.getTime(),
  );
}

export function userDefaultsSet(key: string, value: any) {
  return ReactNativeDeviceActivityModule.userDefaultsSet({ key, value });
}

export function userDefaultsGet<T>(key: string): T | undefined {
  return ReactNativeDeviceActivityModule.userDefaultsGet(key) as T | undefined;
}

export function userDefaultsRemove(key: string) {
  return ReactNativeDeviceActivityModule.userDefaultsRemove(key);
}

export function userDefaultsAll(): Record<string, any> {
  return ReactNativeDeviceActivityModule.userDefaultsAll();
}

export function userDefaultsClear() {
  return ReactNativeDeviceActivityModule.userDefaultsClear();
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

  return ReactNativeDeviceActivityModule.startMonitoring(
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

  ReactNativeDeviceActivityModule.userDefaultsSet(key, actions);
};

export const updateFamilyActivitySelectionToActivityNameMap = ({
  activityName,
  familyActivitySelection,
}: {
  activityName: string;
  familyActivitySelection: string;
}) => {
  const previousValue =
    (ReactNativeDeviceActivityModule.userDefaultsGet(
      "familyActivitySelectionToActivityNameMap",
    ) as Record<string, string>) ?? {};

  ReactNativeDeviceActivityModule.userDefaultsSet(
    "familyActivitySelectionToActivityNameMap",
    {
      ...previousValue,
      [activityName]: familyActivitySelection,
    },
  );
};

export function getAppGroupFileDirectory(): string {
  return ReactNativeDeviceActivityModule.getAppGroupFileDirectory();
}

export function registerManagedStoreListener(
  listener: (event: { activityName: string }) => void,
) {
  const handler = emitter.addListener<{ activityName: string }>(
    "onDeviceActivityDetected",
    listener,
  );

  return handler;
}

export function stopMonitoring(activityNames?: string[]): void {
  return ReactNativeDeviceActivityModule.stopMonitoring(activityNames);
}

export function getActivities(): string[] {
  return ReactNativeDeviceActivityModule.activities();
}

export function isShieldActive(): boolean {
  return ReactNativeDeviceActivityModule.isShieldActive();
}

export function moveFile(
  sourceUri: string,
  destinationUri: string,
  overwrite: boolean = false,
) {
  return ReactNativeDeviceActivityModule.moveFile(
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
  return ReactNativeDeviceActivityModule.copyFile(
    sourceUri,
    destinationUri,
    overwrite,
  );
}

export function isShieldActiveWithSelection(
  familyActivitySelectionStr: string,
): boolean {
  return ReactNativeDeviceActivityModule.isShieldActiveWithSelection(
    familyActivitySelectionStr,
  );
}

export function blockApps(
  familyActivitySelectionStr?: string,
): PromiseLike<void> | void {
  return ReactNativeDeviceActivityModule.blockApps(familyActivitySelectionStr);
}

export function unblockApps(): PromiseLike<void> | void {
  return ReactNativeDeviceActivityModule.unblockApps();
}

export function getAuthorizationStatus(): AuthorizationStatus {
  return ReactNativeDeviceActivityModule.authorizationStatus();
}

const emitter = new EventEmitter(
  ReactNativeDeviceActivityModule ??
    NativeModulesProxy.ReactNativeDeviceActivity,
);

export function addEventReceivedListener(
  listener: (event: DeviceActivityMonitorEventPayload) => void,
): Subscription {
  return emitter.addListener<DeviceActivityMonitorEventPayload>(
    "onDeviceActivityMonitorEvent",
    listener,
  );
}

export function updateShieldConfiguration(
  shieldConfiguration: ShieldConfiguration,
) {
  return ReactNativeDeviceActivityModule.updateShieldConfiguration(
    shieldConfiguration,
  );
}

export function isAvailable(): boolean {
  return Platform.OS === "ios" && parseInt(Platform.Version, 10) >= 15;
}

export {
  DeviceActivitySelectionView,
  DeviceActivitySelectionViewProps as ReactNativeDeviceActivityViewProps,
};
