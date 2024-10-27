import { PropsWithChildren } from "react";
import { NativeSyntheticEvent, StyleProp, ViewStyle } from "react-native";

export type CallbackEventName =
  | "intervalDidStart"
  | "intervalDidEnd"
  | "eventDidReachThreshold"
  | "intervalWillStartWarning"
  | "intervalWillEndWarning"
  | "eventWillReachThresholdWarning";
export type DeviceActivityMonitorEventPayload = {
  callbackName: CallbackEventName;
};

export type EventParsed = {
  activityName: string;
  callbackName: CallbackEventName;
  eventName: string;
  lastCalledAt: Date;
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

export enum AuthorizationStatus {
  notDetermined = 0,
  denied = 1,
  approved = 2,
}

export type ReactNativeDeviceActivityNativeModule = {
  requestAuthorization: () => PromiseLike<void> | void;
  revokeAuthorization: () => PromiseLike<void> | void;
  blockAllApps: () => PromiseLike<void> | void;
  unblockApps: () => PromiseLike<void> | void;
  updateShieldConfiguration: (
    shieldConfiguration: ShieldConfiguration,
  ) => PromiseLike<void> | void;
  getEvents: (onlyEventsForActivityWithName?: string) => EventsLookup;
  activities: () => string[];
  authorizationStatus: () => AuthorizationStatus;
  stopMonitoring: (activityNames?: string[]) => void;
  startMonitoring: (
    activityName: string,
    deviceActivitySchedule: DeviceActivitySchedule,
    deviceActivityEvents: DeviceActivityEventRaw[],
    uniqueSelections: string[],
  ) => void;
};

export type ShieldConfiguration = {
  backgroundColor?: UIColor;
  backgroundBlurStyle?: UIBlurEffectStyle;
  title?: string;
  titleColor?: UIColor;
  subtitle?: string;
  subtitleColor?: UIColor;
  icon?: string;
  primaryButtonLabel?: string;
  primaryButtonLabelColor?: UIColor;
  primaryButtonBackgroundColor?: UIColor;
  secondaryButtonLabel?: string;
  secondaryButtonLabelColor?: UIColor;
};

type UIColor = {
  red: number;
  green: number;
  blue: number;
  alpha?: number;
};

export enum UIBlurEffectStyle {
  extraLight = 0,
  light = 1,
  dark = 2,

  // @available(iOS 10.0, *)
  regular = 4,

  // @available(iOS 10.0, *)
  prominent = 5,

  // @available(iOS 13.0, *)
  systemUltraThinMaterial = 6,

  // @available(iOS 13.0, *)
  systemThinMaterial = 7,

  // @available(iOS 13.0, *)
  systemMaterial = 8,

  // @available(iOS 13.0, *)
  systemThickMaterial = 9,

  // @available(iOS 13.0, *)
  systemChromeMaterial = 10,

  // @available(iOS 13.0, *)
  systemUltraThinMaterialLight = 11,

  // @available(iOS 13.0, *)
  systemThinMaterialLight = 12,

  // @available(iOS 13.0, *)
  systemMaterialLight = 13,

  // @available(iOS 13.0, *)
  systemThickMaterialLight = 14,

  // @available(iOS 13.0, *)
  systemChromeMaterialLight = 15,

  // @available(iOS 13.0, *)
  systemUltraThinMaterialDark = 16,

  // @available(iOS 13.0, *)
  systemThinMaterialDark = 17,

  // @available(iOS 13.0, *)
  systemMaterialDark = 18,

  // @available(iOS 13.0, *)
  systemThickMaterialDark = 19,

  // @available(iOS 13.0, *)
  systemChromeMaterialDark = 20,
}
