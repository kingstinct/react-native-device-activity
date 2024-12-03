[![Test Status](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml/badge.svg)](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml)
[![Latest version on NPM](https://img.shields.io/npm/v/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Downloads on NPM](https://img.shields.io/npm/dt/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Discord](https://dcbadge.vercel.app/api/server/5wQGsRfS?style=flat)](https://discord.gg/5wQGsRfS)

# react-native-device-activity

Provides access to Apples DeviceActivity API. It does require a Custom Dev Client to work with Expo.

Please note that it only supports iOS (and requires iOS 15 or higher). For Android I'd probably look into [UsageStats](https://developer.android.com/reference/android/app/usage/UsageStats), which seems provide more granularity.

# Examples

```TypeScript
import * as ReactNativeDeviceActivity from "react-native-device-activity";

const DeviceActivityPicker = () => {
  // First things first, you need to request authorization
  useEffect(() => {
    ReactNativeDeviceActivity.requestAuthorization()
  }, [])

  const [familyActivitySelection, setFamilyActivitySelection] = React.useState(null);

  // next you need to present a native view to let the user select which activities to track, you need to do this before you can start tracking (this is a completely unstyled clickable native view):
  return (
    <ReactNativeDeviceActivity.DeviceActivitySelectionView
      onSelectionChange={(event) => {
        setFamilyActivitySelection(
          event.nativeEvent.familyActivitySelection
        )
      }}
      familyActivitySelection={familyActivitySelection}>
        <Text>Click here</Text>
    </ReactNativeDeviceActivity.DeviceActivitySelectionView>)
  }
}

// once you have authorization and got hold of the familyActivitySelection (which is a base64 string) you can start tracking with it:
const trackDeviceActivity = (activitySelection: string) => {
  ReactNativeDeviceActivity.startMonitoring(
    "DeviceActivity.AppLoggedTimeDaily",
    {
      // repeat logging every 24 hours
      intervalStart: { hour: 0, minute: 0, second: 0 },
      intervalEnd: { hour: 23, minute: 59, second: 59 },
      repeats: true,
    },
    events: [
      {
        eventName: 'user_activity_reached_10_minutes',
        familyActivitySelection: activitySelection,
        threshold: { minute: 10 },
      }
    ]
  );
}

// you can listen to events (which I guess only works when the app is alive):
const listener = ReactNativeDeviceActivity.onDeviceActivityMonitorEvent(
      (event) => {
        const name = event.nativeEvent.callbackName; // the name of the event
        /* callbackName is one of, corresponding to the events received from the native API:
          - "intervalDidStart"
          - "intervalDidEnd"
          - "eventDidReachThreshold"
          - "intervalWillStartWarning"
          - "intervalWillEndWarning"
          - "eventWillReachThresholdWarning";
        */
      }
    );

// you can also get a history of events called with the time where called:
const events = ReactNativeDeviceActivityModule.getEvents();
```

# Installation in managed Expo projects

For [managed](https://docs.expo.dev/archive/managed-vs-bare/) Expo projects, please follow the installation instructions in the [API documentation for the latest stable release](#api-documentation). If you follow the link and there is no documentation available then this library is not yet usable within managed projects &mdash; it is likely to be included in an upcoming Expo SDK release.

The package requires native code, which includes a custom app target. Currently it requires targeting iOS 15 or higher, so populate app.json/app.config.json as follows:
```
"plugins": [
    [
      "expo-build-properties",
      {
        "ios": {
          "deploymentTarget": "15.0"
        },
      },
    ],
    [
      "react-native-device-activity",
      {
        "appleTeamId": "<YOUR_TEAM_ID>",
      }
    ]
  ],
  ```

The Swift files for the iOS target will be copied to your local `/targets` directory. You might want to add it to your .gitignore.

⚠️ Please note that you need to apply to [apply to use this API](https://developer.apple.com/contact/request/family-controls-distribution) before launching it in AppStore

# Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

### Add the package to your npm dependencies

```
npm install react-native-device-activity
```

### Configure for iOS

Run `npx pod-install` after installing the npm package.



# Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide]( https://github.com/expo/expo#contributing).
