import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import {
  DeviceActivitySelectionSheetViewPersistedProps,
  DeviceActivitySelectionViewPersistedProps,
} from "./ReactNativeDeviceActivity.types";

type NativeSheetViewPersistedProps = DeviceActivitySelectionViewPersistedProps & {
  showNavigationBar: boolean;
  onDismissRequest?:
    DeviceActivitySelectionSheetViewPersistedProps["onDismissRequest"];
};

const NativeView: React.ComponentType<NativeSheetViewPersistedProps> =
  requireNativeViewManager("ReactNativeDeviceActivityViewPersistedModule");

export default function DeviceActivitySelectionSheetViewPersisted(
  props: DeviceActivitySelectionSheetViewPersistedProps,
) {
  return <NativeView {...props} showNavigationBar />;
}
