import * as React from "react";
import { View } from "react-native";

import { DeviceActivityLabelListViewProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivityLabelListView({
	style,
	children,
}: DeviceActivityLabelListViewProps) {
	return <View style={style}>{children}</View>;
}
