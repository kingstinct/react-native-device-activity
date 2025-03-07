import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { DeviceActivitySelectionViewPersistedProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivitySelectionViewPersistedProps> =
  requireNativeViewManager("ReactNativeDeviceActivityViewPersistedModule");

export default function DeviceActivitySelectionViewPersisted(
  props: DeviceActivitySelectionViewPersistedProps,
) {
  return <NativeView {...props} />;
}
