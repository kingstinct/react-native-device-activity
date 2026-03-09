import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { DeviceActivityLabelListViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivityLabelListViewProps> =
	requireNativeViewManager("ReactNativeDeviceActivityLabelListModule");

export default function DeviceActivityLabelListView(
	props: DeviceActivityLabelListViewProps,
) {
	return <NativeView {...props} />;
}
