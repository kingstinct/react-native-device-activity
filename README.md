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
      familyActivitySelection={familyActivitySelection} />
    )
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
        "appGroup": "group.<YOUR_APP_GROUP_NAME>",
      }
    ]
  ],
  ```

The Swift files for the iOS target will be copied to your local `/targets` directory. You might want to add it to your .gitignore (or if you have other targets in there, you might want to specifically add the three targets added by this library).

For Expo to be able to automatically handle provisioning you need to specify extra.eas.build.experimental.ios.appExtensions in your app.json/app.config.ts [as seen here](https://github.com/Intentional-Digital/react-native-device-activity/blob/main/example/app.json#L57).

## Customize native code

You can potentially modify the targets manually, although you risk the library and your app code diverging. If you want to disable the automatic copying of the targets, you can set `copyToTargetFolder` to `false` in the plugin configuration [as seen here](https://github.com/Intentional-Digital/react-native-device-activity/blob/main/example/app.json#L53).

# Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

### Add the package to your npm dependencies

```
npm install react-native-device-activity
```

### Configure for iOS

Run `npx pod-install` after installing the npm package.

## Family Controls (distribution) entitlement requires approval from Apple
As early as possible you want to [request approval from Apple](https://developer.apple.com/contact/request/family-controls-distribution), since it can take time to get approved.

Note that until you have approval for all bundleIdentifiers you want to use, you are stuck with local development builds in XCode. I.e. you can't even build an Expo Dev Client.

For every base bundleIdentifier you need approval for 4 bundleIdentifiers:
- com.your-bundleIdentifier
- com.your-bundleIdentifier.ActivityMonitor
- com.your-bundleIdentifier.ShieldAction
- com.your-bundleIdentifier.ShieldConfiguration

Once you've gotten approval you need to manually add the "Family Controls (Distribution)" under Additional Capabilities for each of the bundleIdentifiers on [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) mentioned above. If you use Expo/EAS this has to be done only once, and after that provisioning will be handled automatically.

⚠️ If you don't do all the above you will run in to a lot of strange provisioning errors.

## Limitations and weird/notable things
- The DeviceActivitySelectionView is prone to crashes, which is outside of our control. The best we can do is provide fallback views that allows the user to know what's happening and reload the view.
- If you've asked about the authorization status once and the user after that revokes it outside the app, the native APIs won't reflect this until the app is restarted.
- requestAuthorization() can be called multiple times, even when the user has already denied permission.


# Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide]( https://github.com/expo/expo#contributing).