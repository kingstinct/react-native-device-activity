import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ReactNativeDeviceActivityViewProps } from './ReactNativeDeviceActivity.types';

const NativeView: React.ComponentType<ReactNativeDeviceActivityViewProps> =
  requireNativeViewManager('ReactNativeDeviceActivity');

export default function ReactNativeDeviceActivityView(props: ReactNativeDeviceActivityViewProps) {
  return <NativeView {...props} />;
}
