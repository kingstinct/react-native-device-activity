import {
  NativeModulesProxy,
  EventEmitter,
  Subscription,
} from "expo-modules-core";

// Import the native module. On web, it will be resolved to ReactNativeDeviceActivity.web.ts
// and on native platforms to ReactNativeDeviceActivity.ts
import { Platform } from "react-native";

import DeviceActivityReportView from "./DeviceActivityReport";
import DeviceActivitySelectionView from "./DeviceActivitySelectionView";
import {
  AuthorizationStatus,
  CallbackEventName,
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

export function stopMonitoring(activityNames?: string[]): void {
  return ReactNativeDeviceActivityModule.stopMonitoring(activityNames);
}

export function getActivities(): string[] {
  return ReactNativeDeviceActivityModule.activities();
}

export function blockAllApps(): PromiseLike<void> | void {
  return ReactNativeDeviceActivityModule.blockAllApps();
}

export function unblockAllApps(): PromiseLike<void> | void {
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
  DeviceActivityReportView,
  DeviceActivitySelectionViewProps as ReactNativeDeviceActivityViewProps,
};
