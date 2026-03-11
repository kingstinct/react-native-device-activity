import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { DeviceActivityReportViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivityReportViewProps> =
	requireNativeViewManager("ReactNativeDeviceActivityReportModule");

export default function DeviceActivityReportView(
	props: DeviceActivityReportViewProps,
) {
	return <NativeView {...props} />;
}
