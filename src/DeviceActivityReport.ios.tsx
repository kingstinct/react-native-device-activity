import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { DeviceActivityReportViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivityReportViewProps> =
  requireNativeViewManager("DeviceActivityReportView");

export default function DeviceActivityReportView({
  style,
  children,
  ...props
}: DeviceActivityReportViewProps) {
  return (
    <NativeView style={style} {...props}>
      {children}
    </NativeView>
  );
}
