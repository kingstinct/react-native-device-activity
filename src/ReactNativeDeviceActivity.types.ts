import { NativeSyntheticEvent, StyleProp, ViewStyle } from "react-native";

export type ChangeEventPayload = {
  selection: Selection;
};

type ActivityCategory = {
  localizedDisplayName?: string;
  token?: string;
};

type Application = {
  localizedDisplayName?: string;
  token?: string;
  bundleIdentifier?: string;
};

type WebDomain = {
  domain?: string;
  token?: string;
};

type Selection = {
  categories: ActivityCategory[];
  applications: Application[];
  webDomains: WebDomain[];
};

export type ReactNativeDeviceActivityViewProps = {
  style: StyleProp<ViewStyle>;
  onSelectionChange?: (
    selection: NativeSyntheticEvent<{ familyActivitySelection: string }>
  ) => void;
  familyActivitySelection?: string | null;
};
