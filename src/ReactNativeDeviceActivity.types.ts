import { PropsWithChildren } from "react";
import { NativeSyntheticEvent, StyleProp, ViewStyle } from "react-native";

export type CallbackEvent =
  | "intervalDidStart"
  | "intervalDidEnd"
  | "eventDidReachThreshold"
  | "intervalWillStartWarning"
  | "intervalWillEndWarning"
  | "eventWillReachThresholdWarning";
export type DeviceActivityMonitorEventPayload = {
  eventName: CallbackEvent;
};

export type EventsLookup = Record<string, number>;

export type DeviceActivitySelectionViewProps = PropsWithChildren<{
  style: StyleProp<ViewStyle>;
  onSelectionChange?: (
    selection: NativeSyntheticEvent<{ familyActivitySelection: string }>,
  ) => void;
  familyActivitySelection?: string | null;
}>;

export type DateComponents = {
  // calendar: Calendar?;
  // timeZone: TimeZone?;
  era?: number;
  year?: number;
  month?: number;
  day?: number;
  hour?: number;
  minute?: number;
  second?: number;
  nanosecond?: number;
  weekday?: number;
  weekdayOrdinal?: number;
  quarter?: number;
  weekOfMonth?: number;
  weekOfYear?: number;
  yearForWeekOfYear?: number;
};

export type DeviceActivitySchedule = {
  intervalStart: DateComponents;
  intervalEnd: DateComponents;
  repeats: boolean;
  warningTime?: DateComponents;
};

export type FamilyActivitySelection = string;

export type DeviceActivityEvent = {
  familyActivitySelection: FamilyActivitySelection;
  threshold: DateComponents;
  eventName: string;
};

export type DeviceActivityEventRaw = Omit<
  DeviceActivityEvent,
  "familyActivitySelection"
> & {
  familyActivitySelectionIndex: number;
};

export type ReactNativeDeviceActivityNativeModule = {
  requestAuthorization: () => PromiseLike<void> | void;
  getEvents: (onlyEventsForActivityWithName?: string) => EventsLookup;
  stopMonitoring: (activityNames?: string[]) => void;
  startMonitoring: (
    activityName: string,
    deviceActivitySchedule: DeviceActivitySchedule,
    deviceActivityEvents: DeviceActivityEventRaw[],
    uniqueSelections: string[],
  ) => void;
};
