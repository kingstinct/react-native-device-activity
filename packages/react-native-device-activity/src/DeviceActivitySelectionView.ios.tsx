import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { DeviceActivitySelectionViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivitySelectionViewProps> =
  requireNativeViewManager("ReactNativeDeviceActivity");

export default function DeviceActivitySelectionView(
  props: DeviceActivitySelectionViewProps,
) {
  return <NativeView {...props} />;
}
