[![Test Status](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml/badge.svg)](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml)
[![Latest version on NPM](https://img.shields.io/npm/v/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Downloads on NPM](https://img.shields.io/npm/dt/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Discord](https://dcbadge.vercel.app/api/server/5wQGsRfS?style=flat)](https://discord.gg/5wQGsRfS)

# react-native-device-activity

Provides direct access to Apples Screen Time, Device Activity and Shielding APIs.

⚠️ Before planning and starting using these APIs it is highly recommended to familiarize yourself with the [special approval and entitlements required](https://github.com/Kingstinct/react-native-device-activity#family-controls-distribution-entitlement-requires-approval-from-apple).

Please note that it only supports iOS (and requires iOS 15 or higher) and requires a Custom Dev Client to work with Expo. For Android I'd probably look into [UsageStats](https://developer.android.com/reference/android/app/usage/UsageStats), which seems provide more granularity.

# Examples & Use Cases

## Handle permissions

To block apps, you need to request Screen Time permissions. Some features (events still seem to trigger in most cases) seem to work without having permissions, but I wouldn't rely on it.

```TypeScript
import * as ReactNativeDeviceActivity from "react-native-device-activity";


useEffect(() => {
  ReactNativeDeviceActivity.requestAuthorization();
}, [])
```

You can also revoke permissions:

```TypeScript
ReactNativeDeviceActivity.revokeAuthorization();
```

## Select Apps to track

For most use cases you need to get an activitySelection from the user, which is a token representing the apps the user wants to track, block or whitelist. This can be done by presenting the native view:

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
```

Some things worth noting here:

- This is a SwiftUI view, which is prone to crashing, especially when browsing larger categories of apps or searching for apps. It's recommended to provide a fallback view (positioned behind the SwiftUI view) that allows the user to know what's happening and reload the view and tailor that to your app's design and UX.
The activitySelection tokens can be particularly large (especially if you use includeEntireCategory flag), so you probably want to reference them through a familyActivitySelectionId instead of always passing the string token around. Most functions in this library accepts a familyActivitySelectionId as well as the familyActivitySelection token directly.

## Time tracking

It's worth noting that the Screen Time API is not designed for time tracking out-of-the-box. So you have to set up events with names you can parse as time after they've triggered.

```TypeScript
import * as ReactNativeDeviceActivity from "react-native-device-activity";

// once you have authorization and got hold of the familyActivitySelection (which is a base64 string) you can start tracking with it:
const trackDeviceActivity = (activitySelection: string) => {
  ReactNativeDeviceActivity.startMonitoring(
    "TimeTrackingActivity",
    {
      // repeat logging every 24 hours
      intervalStart: { hour: 0, minute: 0, second: 0 },
      intervalEnd: { hour: 23, minute: 59, second: 59 },
      repeats: true,
    },
    events: [
      {
        eventName: 'minutes_reached_10', // remember to give event names that make it possible for you to extract time at a later stage, if you want to access this information
        familyActivitySelection: activitySelection,
        threshold: { minute: 10 },
      }
    ]
  );
}

// you can listen to events (which only works when the app is alive):
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

Some things worth noting here:

Depending on your use case (if you need different schedules for different days, for example,) you might need multiple monitors. There's a hard limit on 20 monitors at the same time. Study the [DateComponents](https://developer.apple.com/documentation/foundation/datecomponents) object to model this to your use case. 

## Block the shield

To block apps, you can do it directly from your code.

```TypeScript
import * as ReactNativeDeviceActivity from "react-native-device-activity";

// block all apps
ReactNativeDeviceActivity.blockSelection({
  activitySelectionId: selectionId,
});
```

But for many use cases you want to do this in the Swift process, which is why you can specify actions when setting up events:

```TypeScript
const trackDeviceActivity = (activitySelection: string) => {
  ReactNativeDeviceActivity.startMonitoring(
    "BlockAfter10Minutes",
    {
      // repeat logging every 24 hours
      intervalStart: { hour: 0, minute: 0, second: 0 },
      intervalEnd: { hour: 23, minute: 59, second: 59 },
      repeats: true,
    },
    events: [
      {
        eventName: 'minutes_reached_10', // remember to give event names that make it possible for you to extract time at a later stage, if you want to access this information
        familyActivitySelection: activitySelection,
        threshold: { minute: 10 },
        actions: [
          {
            type: "blockSelection",
            familyActivitySelectionId,
          }
        ]
      }
    ]
  );
}
```

There are many other actions you can perform, like sending web requests or notifications. The easiest way to explore this is by using TypeScript, which is easier to keep up-to-date than this documentation.

You can also configure the shield UI and actions of the shield (this can also be done in the Swift process with actions):

```TypeScript
ReactNativeDeviceActivity.updateShield(
  {
    title: shieldTitle,
    backgroundBlurStyle: UIBlurEffectStyle.systemMaterialDark,
    // backgroundColor: null,
    titleColor: {
      red: 255,
      green: 0,
      blue: 0,
    },
    subtitle: "subtitle",
    subtitleColor: {
      red: Math.random() * 255,
      green: Math.random() * 255,
      blue: Math.random() * 255,
    },
    primaryButtonBackgroundColor: {
      red: Math.random() * 255,
      green: Math.random() * 255,
      blue: Math.random() * 255,
    },
    primaryButtonLabelColor: {
      red: Math.random() * 255,
      green: Math.random() * 255,
      blue: Math.random() * 255,
    },
    secondaryButtonLabelColor: {
      red: Math.random() * 255,
      green: Math.random() * 255,
      blue: Math.random() * 255,
    },
  },
  {
    primary: {
      type: "disableBlockAllMode",
      behavior: "defer",
    },
    secondary: {
      type: "dismiss",
      behavior: "close",
    },
  },
)
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
          "deploymentTarget": "15.1"
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

## Some notes

- It's not possible to 100% know which familyActivitySelection an event being handled is triggered for in the context of the Shield UI/actions. We try to make the best guess here, prioritizing apps/websites in an activitySelection over categories, and smaller activitySelections over larger ones (i.e. "Instagram" over "Instagram + Facebook" over "Social Media Apps"). This means that if you display a shield specific for the Instagram selection that will take precedence over the less specific shields.
- When determining which familyActivitySelectionId that should be used it will only look for familyActivitySelectionIds that are contained in any of the currently monitored activity names (i.e. if familyActivitySelectionId is "social-media-apps" it will only trigger if there is an activity name that contains "social-media-apps"). This might be a limitation for some implementations, it would probably be nice to make this configurable.

## Data model

Almost all the functionality is built around persisting configuration as well as event history to UserDefaults.

- familyActivitySelectionId mapping. This makes it possible for us to tie a familyActivitySelection token to an id that we can reuse and refer to at a later stage.
- Triggers. This includes configuring shield UI/actions as well as sending web requests or notifications from the Swift background side, in the context of the device activity monitor process. Prefixed like actions*for*${goalId} in userDefaults. This is how we do blocking of apps, updates to shield UI/actions etc.
- Event history. Contains information of which events have been triggered and when. Prefixed like events\_${goalId} in userDefaults. This can be useful for tracking time spent.
- ShieldIds. To reduce the storage strain on userDefaults shields are referenced with shieldIds.

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

For every base bundleIdentifier you need approval for 4 bundleIdentifiers (if you want to use all the native extensions that is, you can potentially just use the Shield-related ones if you have no need to listen to the events, or similarly just use the ActivityMonitor if you do not need control over the Shield UI):

- com.your-bundleIdentifier
- com.your-bundleIdentifier.ActivityMonitor
- com.your-bundleIdentifier.ShieldAction
- com.your-bundleIdentifier.ShieldConfiguration

Once you've gotten approval you need to manually add the "Family Controls (Distribution)" under Additional Capabilities for each of the bundleIdentifiers on [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) mentioned above. If you use Expo/EAS this has to be done only once, and after that provisioning will be handled automatically.

⚠️ If you don't do all the above you will run in to a lot of strange provisioning errors.

# Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide](https://github.com/expo/expo#contributing).

# Weird behaviors ⚠️

- Authorization changes outside app not captured
  When we've asked whether the user has authorized us to use screen time, and the state is changed outside the app, the native API doesn't update until the app restarts, i.e. this flow:

  1. Ask for current permission
  2. Change permission outside the app
  3. Ask for current permission again will return same as (1)
  4. **Workaround: restart the app**

- We can both request and revoke permissions as we like, and how many times we like, even when the user has denied permissions. This is very unlike most authorization flows on iOS.

- When calling `getAuthorizationStatus` it can sometimes return `notDetermined` even though the user has already made a choice, this comes with a delay. Workaround: keep polling the status for a while (`pollAuthorizationStatus` is a convenience function for this).

- The DeviceActivitySelectionView is prone to crashes, which is outside of our control. The best we can do is provide fallback views that allows the user to know what's happening and reload the view.

# Troubleshooting 📱

The Screen Time APIs are known to be very finnicky. Here are some things you can try to troubleshoot events not being reported:

- Disable Low Power Mode (mentioned by Apple Community Specialist [here](https://discussions.apple.com/thread/254808070)) 🪫
- Turn off/turn on app & website activity
- Disable/reenable sync between devices for screen time
- Restart device
- Make sure device is not low on storage (mentioned by Apple Community Specialist [here](https://discussions.apple.com/thread/254808070)) 💾
- Upgrade iOS version
- Content & Privacy Restrictions: If any restrictions are enabled under Screen Time’s Content & Privacy Restrictions, ensure none are blocking your app.
- Reset all device settings
