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
  eventName?: string;
  lastCalledAt: Date;
};

export type EventsLookup = Record<string, number>;

export type DeviceActivitySelectionEvent = {
  familyActivitySelection: string;
  applicationCount: number;
  categoryCount: number;
  webDomainCount: number;
};

export type DeviceActivitySelectionViewProps = PropsWithChildren<{
  style: StyleProp<ViewStyle>;
  onSelectionChange?: (
    selection: NativeSyntheticEvent<DeviceActivitySelectionEvent>,
  ) => void;
  familyActivitySelection?: string | null;
  headerText?: string | null;
  footerText?: string | null;
}>;

/**
 * @link https://developer.apple.com/documentation/foundation/datecomponents
 */
export type DateComponents = {
  // calendar: Calendar?;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779909-era
   */
  era?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779943-year
   */
  year?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1780256-month
   */
  month?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779808-day
   */
  day?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779899-hour
   */
  hour?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779900-minute
   */
  minute?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779901-second
   */
  second?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779902-nanosecond
   */
  nanosecond?: number;
  /**
   * @link https://developer.apple.com/documentation/foundation/datecomponents/1779903-weekday
   */
  weekday?: number;
  weekdayOrdinal?: number;
  quarter?: number;
  weekOfMonth?: number;
  weekOfYear?: number;
  yearForWeekOfYear?: number;

  /**
   * mapped to init(identifier:)
   * @link https://developer.apple.com/documentation/foundation/timezone/3126780-init
   * or init(abbreviation:)
   * @link https://developer.apple.com/documentation/foundation/timezone/3126779-init
   */
  timeZoneIdentifier?: string;

  /**
   * mapped to init(secondsFromGMT:)
   * @link https://developer.apple.com/documentation/foundation/timezone/2293718-init
   */
  timeZoneOffsetInSeconds?: number;
};

/**
 * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule
 */
export type DeviceActivitySchedule = {
  /**
   * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/intervalstart
   */
  intervalStart: DateComponents;
  /**
   * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/intervalend
   */
  intervalEnd: DateComponents;
  /**
   * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/repeats
   */
  repeats: boolean;
  /**
   * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/warningtime
   */
  warningTime?: DateComponents;
};

export type FamilyActivitySelection = string;

export type DeviceActivityEvent = {
  familyActivitySelection: FamilyActivitySelection;
  threshold: DateComponents;
  eventName: string;
  /**
   * @link https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/includespastactivity
   */
  includesPastActivity?: boolean;
};

export type ShieldActionType =
  | "unblockAll"
  | "dismiss"
  | "unblockCurrentApp"
  | "sendNotification"
  | "openApp";

export type ShieldAction = {
  type: ShieldActionType;
  delay?: number;
  payload?: NotificationPayload;
  behavior: "close" | "defer";
};

export type ShieldActions = {
  primary: ShieldAction;
  secondary?: ShieldAction;
};

export type NotificationPayload = {
  title: string;
  body: string;
  sound?: "default" | "defaultCritical" | "defaultRingtone";
  categoryIdentifier?: string;
  badge?: number;
  userInfo?: Record<string, any>;
  interruptionLevel?: "active" | "critical" | "passive";
  targetContentIdentifier?: string;
  launchImageName?: string;
  identifier?: string;
  threadIdentifier?: string;
  subtitle?: string;
};

type CommonTypeParams = {
  sleepBefore?: number;
  sleepAfter?: number;
  skipIfAlreadyTriggeredBetween?: {
    fromDate?: Date;
    toDate?: Date;
  };
  skipIfAlreadyTriggeredAfter?: Date;
  skipIfLargerEventRecordedAfter?: Date;
  skipIfAlreadyTriggeredWithinMS?: number;
  skipIfLargerEventRecordedWithinMS?: number;
  skipIfAlreadyTriggeredBefore?: Date;
  skipIfLargerEventRecordedSinceIntervalStarted?: boolean;
  neverTriggerBefore?: Date;
};

export type Action =
  | ({
      type: "blockSelection";
      familyActivitySelectionId: string;
      shieldId?: string;
    } & CommonTypeParams)
  | ({
      type: "unblockAllApps";
    } & CommonTypeParams)
  | ({
      type: "resetUnblockedSelection";
    } & CommonTypeParams)
  | ({
      type: "blockAllApps";
      shieldId?: string;
    } & CommonTypeParams)
  | ({
      type: "sendNotification";
      payload: NotificationPayload;
    } & CommonTypeParams)
  | ({
      type: "openApp";
    } & CommonTypeParams)
  | ({
      type: "sendHttpRequest";
      url: string;
      options?: {
        method?: "GET" | "POST" | "PUT" | "DELETE";
        body?: Record<string, any>;
        headers?: Record<string, string>;
      };
    } & CommonTypeParams);

export type DeviceActivityEventRaw = Omit<
  DeviceActivityEvent,
  "familyActivitySelection"
> & {
  familyActivitySelectionIndex: number;
};

export const AuthorizationStatus = {
  notDetermined: 0,
  denied: 1,
  approved: 2,
} as const;

export type AuthorizationStatusType =
  (typeof AuthorizationStatus)[keyof typeof AuthorizationStatus];

export type CallbackName =
  | "intervalDidStart"
  | "intervalWillStartWarning"
  | "intervalDidEnd"
  | "intervalWillEndWarning"
  | "eventDidReachThreshold"
  | "eventWillReachThresholdWarning";

export type ReactNativeDeviceActivityNativeModule = {
  userDefaultsSet: (dict: any) => void;
  userDefaultsGet: (key: string) => any;
  userDefaultsRemove: (key: string) => void;
  userDefaultsClear: () => void;
  userDefaultsAll: () => any;
  requestAuthorization: (
    forIndividualOrChild: "individual" | "child",
  ) => PromiseLike<void> | void;
  revokeAuthorization: () => PromiseLike<void> | void;
  blockApps: (
    familyActivitySelectionStr?: string,
    triggeredBy?: string,
  ) => void;
  blockAppsWithSelectionId: (
    familyActivitySelectionId: string,
    triggeredBy?: string,
  ) => void;
  unblockApps: (triggeredBy?: string) => void;
  isShieldActive: () => boolean;
  isShieldActiveWithSelection: (familyActivitySelectionStr: string) => boolean;
  doesSelectionHaveOverlap: (
    familyActivitySelections: FamilyActivitySelection[],
  ) => boolean;
  getEvents: (onlyEventsForActivityWithName?: string) => EventsLookup;
  activities: () => string[];
  authorizationStatus: () => AuthorizationStatusType;
  stopMonitoring: (activityNames?: string[]) => void;
  reloadDeviceActivityCenter: () => void;
  startMonitoring: (
    activityName: string,
    deviceActivitySchedule: DeviceActivitySchedule,
    deviceActivityEvents: DeviceActivityEventRaw[],
    uniqueSelections: string[],
  ) => void;
};

/**
 * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration
 */
export type ShieldConfiguration = {
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/backgroundblurstyle
   */
  backgroundColor?: UIColor;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/backgroundblurstyle
   */
  backgroundBlurStyle?: (typeof UIBlurEffectStyle)[keyof typeof UIBlurEffectStyle];
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/title
   */
  title?: string;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/label/color
   */
  titleColor?: UIColor;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/subtitle
   */
  subtitle?: string;
  subtitleColor?: UIColor;
  /**
   * Use an image from the app group directory.
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/icon
   */
  iconAppGroupRelativePath?: string;
  /**
   * Use SF Symbols for the icon.
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/icon
   * @link https://developer.apple.com/sf-symbols/
   */
  iconSystemName?: string;

  /**
   * Add a tint color to the icon.
   */
  iconTint?: UIColor;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/primarybuttonlabel
   */
  primaryButtonLabel?: string;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/label/color
   */
  primaryButtonLabelColor?: UIColor;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/primarybuttonbackgroundcolor
   */
  primaryButtonBackgroundColor?: UIColor;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/secondarybuttonlabel
   */
  secondaryButtonLabel?: string;
  /**
   * @link https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration/label/color
   */
  secondaryButtonLabelColor?: UIColor;
};

/**
 * @link https://developer.apple.com/documentation/uikit/uicolor
 * @property {number} red (0-255)
 * @property {number} green (0-255)
 * @property {number} blue (0-255)
 * @property {number} alpha (0-1)
 */
type UIColor = {
  /**
   * Red (0-255)
   */
  red: number;
  /**
   * Green (0-255)
   */
  green: number;
  /**
   * Blue (0-255)
   */
  blue: number;
  /**
   * Alpha (0-1)
   */
  alpha?: number;
};

export const UIBlurEffectStyle = {
  extraLight: 0,
  light: 1,
  dark: 2,

  // @available(iOS 10.0, *)
  regular: 4,

  // @available(iOS 10.0, *)
  prominent: 5,

  // @available(iOS 13.0, *)
  systemUltraThinMaterial: 6,

  // @available(iOS 13.0, *)
  systemThinMaterial: 7,

  // @available(iOS 13.0, *)
  systemMaterial: 8,

  // @available(iOS 13.0, *)
  systemThickMaterial: 9,

  // @available(iOS 13.0, *)
  systemChromeMaterial: 10,

  // @available(iOS 13.0, *)
  systemUltraThinMaterialLight: 11,

  // @available(iOS 13.0, *)
  systemThinMaterialLight: 12,

  // @available(iOS 13.0, *)
  systemMaterialLight: 13,

  // @available(iOS 13.0, *)
  systemThickMaterialLight: 14,

  // @available(iOS 13.0, *)
  systemChromeMaterialLight: 15,

  // @available(iOS 13.0, *)
  systemUltraThinMaterialDark: 16,

  // @available(iOS 13.0, *)
  systemThinMaterialDark: 17,

  // @available(iOS 13.0, *)
  systemMaterialDark: 18,

  // @available(iOS 13.0, *)
  systemThickMaterialDark: 19,

  // @available(iOS 13.0, *)
  systemChromeMaterialDark: 20,
} as const;
