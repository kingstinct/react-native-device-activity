import * as React from "react";
import { View } from "react-native";

import { DeviceActivitySelectionViewProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivitySelectionView({
  style,
  children,
  ...props
}: DeviceActivitySelectionViewProps) {
  return <View style={style}>{children}</View>;
}
