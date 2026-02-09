import * as React from "react";
import { View } from "react-native";

import { DeviceActivitySelectionSheetViewPersistedProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivitySelectionSheetViewPersisted({
  style,
  children,
}: DeviceActivitySelectionSheetViewPersistedProps) {
  return <View style={style}>{children}</View>;
}
