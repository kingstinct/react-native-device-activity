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

export type ActivitySelectionMetadata = {
  applicationCount: number;
  categoryCount: number;
  webDomainCount: number;
  includeEntireCategory: boolean;
};

export type ActivitySelectionWithMetadata = {
  familyActivitySelection: string | null;
} & ActivitySelectionMetadata;

export type DeviceActivitySelectionEvent = ActivitySelectionWithMetadata;

export type DeviceActivitySelectionViewProps = PropsWithChildren<{
  style?: StyleProp<ViewStyle>;
  onSelectionChange?: (
    selection: NativeSyntheticEvent<DeviceActivitySelectionEvent>,
  ) => void;
  familyActivitySelection?: string | null;
  headerText?: string | null;
  footerText?: string | null;
}>;

export type DeviceActivitySelectionViewPersistedProps = PropsWithChildren<{
  style?: StyleProp<ViewStyle>;
  onSelectionChange?: (
    selection: NativeSyntheticEvent<ActivitySelectionMetadata>,
  ) => void;
  familyActivitySelectionId: string;
  headerText?: string | null;
  footerText?: string | null;
  includeEntireCategory?: boolean;
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
  | "disableBlockAllMode"
  | "dismiss"
  | "unblockCurrentApp"
  | "resetBlocks"
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
      // keeping this for now - since it breaks the shield by sending in a token
      familyActivitySelectionId: string;
      shieldId?: string; // maybe consider moving to its own action
    } & CommonTypeParams)
  | ({
      type: "unblockSelection";
      // keeping this for now - since it breaks the shield by sending in a token
      familyActivitySelectionId: string;
    } & CommonTypeParams)
  | ({
      type: "enableBlockAllMode";
      shieldId?: string; // maybe consider moving to its own action
    } & CommonTypeParams)
  | ({
      type: "disableBlockAllMode";
    } & CommonTypeParams)
  | ({
      type: "addSelectionToWhitelist";
      familyActivitySelection: ActivitySelectionInput;
    } & CommonTypeParams)
  | ({
      type: "removeSelectionFromWhitelist";
      familyActivitySelection: ActivitySelectionInput;
    } & CommonTypeParams)
  | ({
      type: "clearWhitelist";
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
  /** Authorization status has not been determined yet */
  notDetermined: 0,
  /** Authorization has been denied */
  denied: 1,
  /** Authorization has been approved */
  approved: 2,
} as const;

/**
 * Represents the authorization status for device activity monitoring.
 * Values:
 * - 0: Authorization not determined yet
 * - 1: Authorization denied
 * - 2: Authorization approved
 */
export type AuthorizationStatusType =
  | typeof AuthorizationStatus.notDetermined
  | typeof AuthorizationStatus.denied
  | typeof AuthorizationStatus.approved;

export type CallbackName =
  | "intervalDidStart"
  | "intervalWillStartWarning"
  | "intervalDidEnd"
  | "intervalWillEndWarning"
  | "eventDidReachThreshold"
  | "eventWillReachThresholdWarning";

export type ActivitySelectionInput =
  | {
      activitySelectionId: string;
      activitySelectionToken?: undefined;
      currentBlocklist?: undefined;
      currentWhitelist?: undefined;
    }
  | {
      activitySelectionToken: string;
      activitySelectionId?: undefined;
      currentBlocklist?: undefined;
      currentWhitelist?: undefined;
    };

export type ActivitySelectionInputWithBlocks =
  | {
      currentBlocklist: true;
      currentWhitelist?: undefined;
      activitySelectionToken?: undefined;
      activitySelectionId?: undefined;
    }
  | {
      currentWhitelist: true;
      currentBlocklist?: undefined;
      activitySelectionToken?: undefined;
      activitySelectionId?: undefined;
    }
  | ActivitySelectionInput;

export type SetOperationOptions = {
  stripToken?: boolean;
  persistAsActivitySelectionId?: string;
};

export type ReactNativeDeviceActivityNativeModule = {
  // userDefaults functions
  userDefaultsSet: (dict: any) => void;
  userDefaultsGet: (key: string) => any;
  userDefaultsRemove: (key: string) => void;
  userDefaultsClear: () => void;
  userDefaultsAll: () => Record<string, any>;
  // metadata and set functions
  activitySelectionMetadata: (
    familyActivitySelection: ActivitySelectionInputWithBlocks,
  ) => ActivitySelectionMetadata;
  activitySelectionWithMetadata: (
    familyActivitySelection: ActivitySelectionInputWithBlocks,
  ) => ActivitySelectionWithMetadata;
  convertToIncludeCategories: (
    familyActivitySelection: ActivitySelectionInputWithBlocks,
  ) => ActivitySelectionWithMetadata;
  intersection: (
    familyActivitySelectionOne: ActivitySelectionInputWithBlocks,
    familyActivitySelectionTwo: ActivitySelectionInputWithBlocks,
    options: SetOperationOptions,
  ) => ActivitySelectionWithMetadata;
  union: (
    familyActivitySelectionOne: ActivitySelectionInputWithBlocks,
    familyActivitySelectionTwo: ActivitySelectionInputWithBlocks,
    options: SetOperationOptions,
  ) => ActivitySelectionWithMetadata;
  difference: (
    familyActivitySelectionOne: ActivitySelectionInputWithBlocks,
    familyActivitySelectionTwo: ActivitySelectionInputWithBlocks,
    options: SetOperationOptions,
  ) => ActivitySelectionWithMetadata;
  symmetricDifference: (
    familyActivitySelectionOne: ActivitySelectionInputWithBlocks,
    familyActivitySelectionTwo: ActivitySelectionInputWithBlocks,
    options: SetOperationOptions,
  ) => ActivitySelectionWithMetadata;

  renameActivitySelection: (
    previousFamilyActivitySelectionId: string,
    newFamilyActivitySelectionId: string,
  ) => void;

  // auth functions
  requestAuthorization: (
    forIndividualOrChild: "individual" | "child",
  ) => PromiseLike<void>;
  revokeAuthorization: () => PromiseLike<void>;
  authorizationStatus: () => AuthorizationStatusType;

  // blocklist functions
  unblockSelection: (
    familyActivitySelection: ActivitySelectionInput,
    triggeredBy?: string,
  ) => void;
  blockSelection: (
    familyActivitySelection: ActivitySelectionInput,
    triggeredBy?: string,
  ) => void;
  enableBlockAllMode: (triggeredBy?: string) => void;
  // clears the blocklist and removes the shield (does not automatically clear the whitelist)
  disableBlockAllMode: (triggeredBy?: string) => void;

  resetBlocks: (triggeredBy?: string) => void;

  removeSelectionFromWhitelistAndUpdateBlock: (
    familyActivitySelection: ActivitySelectionInput,
    triggeredBy?: string,
  ) => void;
  addSelectionToWhitelistAndUpdateBlock: (
    familyActivitySelection: ActivitySelectionInput,
    triggeredBy?: string,
  ) => void;
  clearWhitelistAndUpdateBlock: (triggeredBy?: string) => void;
  clearWhitelist: () => void;

  // reset, reload things
  reloadDeviceActivityCenter: () => void;
  refreshManagedSettingsStore: () => void;
  clearAllManagedSettingsStoreSettings: () => void;

  // monitoring
  stopMonitoring: (activityNames?: string[]) => void;
  startMonitoring: (
    activityName: string,
    deviceActivitySchedule: DeviceActivitySchedule,
    deviceActivityEvents: DeviceActivityEventRaw[],
    uniqueSelections: string[],
  ) => void;

  isShieldActive: () => boolean;
  getEvents: (onlyEventsForActivityWithName?: string) => EventsLookup;
  activities: () => string[];
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
