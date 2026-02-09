import * as React from "react";
import { View } from "react-native";

import { DeviceActivitySelectionSheetViewProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivitySelectionSheetView({
  style,
  children,
}: DeviceActivitySelectionSheetViewProps) {
  return <View style={style}>{children}</View>;
}
