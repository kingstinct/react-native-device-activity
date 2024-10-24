import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ReactNativeDeviceActivity.web.ts
// and on native platforms to ReactNativeDeviceActivity.ts
import ReactNativeDeviceActivityModule from './ReactNativeDeviceActivityModule';
import ReactNativeDeviceActivityView from './ReactNativeDeviceActivityView';
import { ChangeEventPayload, ReactNativeDeviceActivityViewProps } from './ReactNativeDeviceActivity.types';

// Get the native constant value.
export const PI = ReactNativeDeviceActivityModule.PI;

export function hello(): string {
  return ReactNativeDeviceActivityModule.hello();
}

export async function setValueAsync(value: string) {
  return await ReactNativeDeviceActivityModule.setValueAsync(value);
}

const emitter = new EventEmitter(ReactNativeDeviceActivityModule ?? NativeModulesProxy.ReactNativeDeviceActivity);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ReactNativeDeviceActivityView, ReactNativeDeviceActivityViewProps, ChangeEventPayload };
