import * as React from 'react';

import { ReactNativeDeviceActivityViewProps } from './ReactNativeDeviceActivity.types';

export default function ReactNativeDeviceActivityView(props: ReactNativeDeviceActivityViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
