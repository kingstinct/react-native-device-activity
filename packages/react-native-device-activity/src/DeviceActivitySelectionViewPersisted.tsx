import * as React from "react";
import { View } from "react-native";

import { DeviceActivitySelectionViewPersistedProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivitySelectionViewPersisted({
  style,
  children,
  ...props
}: DeviceActivitySelectionViewPersistedProps) {
  return <View style={style}>{children}</View>;
}
