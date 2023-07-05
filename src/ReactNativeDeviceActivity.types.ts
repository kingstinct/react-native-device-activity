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
  onChange?: (selection: Selection) => void;
};
