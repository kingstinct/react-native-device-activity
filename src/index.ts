import {
  NativeModulesProxy,
  EventEmitter,
  Subscription,
} from "expo-modules-core";

// Import the native module. On web, it will be resolved to ReactNativeDeviceActivity.web.ts
// and on native platforms to ReactNativeDeviceActivity.ts
import {
  ChangeEventPayload,
  ReactNativeDeviceActivityViewProps,
} from "./ReactNativeDeviceActivity.types";
import ReactNativeDeviceActivityModule from "./ReactNativeDeviceActivityModule";
import ReactNativeDeviceActivityView from "./ReactNativeDeviceActivityView";

// Get the native constant value.
export const PI = ReactNativeDeviceActivityModule.PI;

export function hello(): string {
  return ReactNativeDeviceActivityModule.hello();
}

export async function setValueAsync(value: string) {
  return await ReactNativeDeviceActivityModule.setValueAsync(value);
}

export async function requestAuthorization(): Promise<void> {
  return await ReactNativeDeviceActivityModule.requestAuthorization();
}

export function getEvents(): unknown[] {
  return ReactNativeDeviceActivityModule.getEvents();
}

export async function startMonitoring(): Promise<void> {
  return await ReactNativeDeviceActivityModule.startMonitoring();
}

export async function stopMonitoring(): Promise<void> {
  return await ReactNativeDeviceActivityModule.stopMonitoring();
}

const emitter = new EventEmitter(
  ReactNativeDeviceActivityModule ??
    NativeModulesProxy.ReactNativeDeviceActivity
);

export function addSelectionChangeListener(
  listener: (event: ChangeEventPayload) => void
): Subscription {
  return emitter.addListener<ChangeEventPayload>("onSelectionChange", listener);
}

export {
  ReactNativeDeviceActivityView,
  ReactNativeDeviceActivityViewProps,
  ChangeEventPayload,
};
