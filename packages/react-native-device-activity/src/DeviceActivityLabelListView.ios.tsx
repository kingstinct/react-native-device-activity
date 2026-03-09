import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";
import { NativeSyntheticEvent } from "react-native";

import { DeviceActivityLabelListViewProps } from "./ReactNativeDeviceActivity.types";

type NativeProps = DeviceActivityLabelListViewProps & {
	onContentSizeChange?: (
		event: NativeSyntheticEvent<{ height: number }>,
	) => void;
};

const NativeView: React.ComponentType<NativeProps> = requireNativeViewManager(
	"ReactNativeDeviceActivityLabelListModule",
);

export default function DeviceActivityLabelListView(
	props: DeviceActivityLabelListViewProps,
) {
	const [height, setHeight] = React.useState(0);

	return (
		<NativeView
			{...props}
			style={[props.style, height > 0 && { height }]}
			onContentSizeChange={(e) => setHeight(e.nativeEvent.height)}
		/>
	);
}
