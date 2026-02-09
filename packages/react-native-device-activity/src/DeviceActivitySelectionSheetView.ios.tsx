import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import {
  DeviceActivitySelectionSheetViewProps,
  DeviceActivitySelectionViewProps,
} from "./ReactNativeDeviceActivity.types";

type NativeSheetViewProps = DeviceActivitySelectionViewProps & {
  showNavigationBar: boolean;
  onDismissRequest?: DeviceActivitySelectionSheetViewProps["onDismissRequest"];
};

const NativeView: React.ComponentType<NativeSheetViewProps> =
  requireNativeViewManager("ReactNativeDeviceActivity");

export default function DeviceActivitySelectionSheetView(
  props: DeviceActivitySelectionSheetViewProps,
) {
  return <NativeView {...props} showNavigationBar />;
}
