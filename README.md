# react-native-device-activity

[![Test Status](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml/badge.svg)](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml)
[![Latest version on NPM](https://img.shields.io/npm/v/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Downloads on NPM](https://img.shields.io/npm/dt/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Discord](https://dcbadge.vercel.app/api/server/hrgnETpsJA?style=flat)](https://discord.gg/hrgnETpsJA)

React Native wrapper for Apple's Screen Time, Device Activity, and Family Controls APIs.

⚠️ **Important**: These APIs require [special approval and entitlements from Apple](https://github.com/Kingstinct/react-native-device-activity#family-controls-distribution-entitlement-requires-approval-from-apple). Request this approval as early as possible in your development process.

## Table of Contents

- [Apple's Screen Time APIs Explained](https://developer.apple.com/videos/play/wwdc2021/10123/)
  - [FamilyControl API](#familycontrol-api)
  - [ShieldConfiguration API](#shieldconfiguration-api)
  - [ShieldAction API](#shieldaction-api)
  - [ActivityMonitor API](#activitymonitor-api)
- [Installation in managed Expo projects](#installation-in-managed-expo-projects)
  - [Some Notes](#some-notes)
  - [Data model](#data-model)
- [Installation in bare React Native projects](#installation-in-bare-react-native-projects)
- [Family Controls (distribution) entitlement requires approval from Apple](#family-controls-distribution-entitlement-requires-approval-from-apple)
- [Basic Example: Event Tracking Approach](#basic-example-event-tracking-approach)
- [Select Apps to track](#select-apps-to-track)
- [Time tracking](#time-tracking)
- [Block the shield](#block-the-shield)
- [Alternative Example: Blocking Apps for a Time Slot](#alternative-example-blocking-apps-for-a-time-slot)
  - [Key Concepts Explained](#key-concepts-explained)
- [API Reference](#api-reference-the-list-is-not-exhaustive-yet-please-refer-to-the-typescript-types-for-the-full-list)
  - [Components](#components)
  - [Hooks](#hooks)
  - [Functions](#functions)
- [Contributing](#contributing)
- [Weird behaviors ⚠️](#weird-behaviors-)
- [Troubleshooting 📱](#troubleshooting-)

## Apple's Screen Time APIs Explained

_(See [WWDC21](https://www.youtube.com/watch?v=DKH0cw9LhtM) for official details.)_

Note: Depending on your use case, you might not need all the APIs hence not all the new bundle identifier and capabilities are required. Below is a quick overview of the APIs available.

### FamilyControl API

The FamilyControl API allows your app to access Screen Time data and manage restrictions on apps and websites.

**What it does**: Provides access to selection and monitoring of app/website usage
**Example**: Selecting which apps (e.g., Instagram, TikTok) to monitor or block

### ShieldConfiguration API

Defines the visual appearance and text shown when users attempt to access blocked content.

**What it does**: Customizes the blocking screen UI
**Example**:

```typescript
const shieldConfig = {
  title: "Time for a Break!",
  subtitle: "These apps are unavailable until midnight.",
  primaryButtonLabel: "OK",
  iconSystemName: "moon.stars.fill",
};
```

### ShieldAction API

Defines what happens when users interact with shield buttons.

**What it does**: Controls behavior when users tap buttons on the shield
**Example**:

```typescript
const shieldActions = {
  primary: {
    behavior: "close", // Just close the shield when OK is tapped
  },
};
```

### ActivityMonitor API

Schedules and manages when restrictions should be applied or removed. This is what will activate the shield when your app is killed.

**What it does**: Monitors device activity against schedules and thresholds
**Example**:

```typescript
// Block social media from 7PM to midnight daily
ReactNativeDeviceActivity.startMonitoring(
  "evening_block",
  {
    intervalStart: { hour: 19, minute: 0 },
    intervalEnd: { hour: 23, minute: 59 },
    repeats: true,
  },
  [],
);
```

## Installation in managed Expo projects

1. Install the package:

   ```bash
   npm install react-native-device-activity
   # or
   yarn add react-native-device-activity
   ```

2. Configure the Expo plugin in your `app.json` or `app.config.js`:

   ```json
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
           "appGroup": "group.<YOUR_APP_GROUP_NAME>"
         }
       ]
     ],
   ```

3. Generate the native projects:

   ```bash
   npx expo prebuild --platform ios
   ```

4. Verify Xcode Targets: After running prebuild, open the `ios` directory in Xcode (`open ios/YourProject.xcworkspace`). Check that you have the following targets in addition to your main app target:

- `ActivityMonitorExtension`
- `ShieldAction`
- `ShieldConfiguration`

### Some Notes

- It's not possible to 100% know which familyActivitySelection an event being handled is triggered for in the context of the Shield UI/actions. We try to make a best guess here - prioritizing apps/websites in an activitySelection over categories, and smaller activitySelections over larger ones (i.e. "Instagram" over "Instagram + Facebook" over "Social Media Apps"). This means that if you display a shield specific for the Instagram selection that will take precedence over the less specific shields.
- When determining which familyActivitySelectionId that should be used, it will only look for familyActivitySelectionIds that are contained in any of the currently monitored activity names (i.e. if familyActivitySelectionId is "social-media-apps" it will only trigger if there is an activity name that contains "social-media-apps"). This might be a limitation for some implementations, it would probably be nice to make this configurable.

### Data model

Almost all the functionality is built around persisting configuration as well as event history to UserDefaults.

- familyActivitySelectionId mapping. This makes it possible for us to tie a familyActivitySelection token to an id that we can reuse and refer to at a later stage.
- Triggers. This includes configuring shield UI/actions as well as sending web requests or notifications from the Swift background side, in the context of the device activity monitor process. Prefixed like actions*for*${goalId} in userDefaults. This is how we do blocking of apps, updates to shield UI/actions etc.
- Event history. Contains information of which events have been triggered and when. Prefixed like events\_${goalId} in userDefaults. This can be useful for tracking time spent.
- ShieldIds. To reduce the storage strain on userDefaults shields are referenced with shieldIds.

## Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

### Add the package to your npm dependencies

```bash
npm install react-native-device-activity
```

### Configure for iOS

Run `npx pod-install` after installing the npm package.

## Family Controls (distribution) entitlement requires approval from Apple

As early as possible you want to [request approval from Apple](https://developer.apple.com/contact/request/family-controls-distribution), since it can take time to get approved.

Note that until you have approval for all bundleIdentifiers you want to use, you are stuck with local development builds in XCode. i.e., you can't even build an Expo Dev Client.

For every base bundleIdentifier you need approval for 4 bundleIdentifiers (when leveraging all native extensions that is, you can potentially just use the Shield-related ones if you have no need to listen to the events, or similarly just use the ActivityMonitor if you do not need control over the Shield UI):

- `com.your-bundleIdentifier`
- `com.your-bundleIdentifier.ActivityMonitor`
- `com.your-bundleIdentifier.ShieldAction`
- `com.your-bundleIdentifier.ShieldConfiguration`

Once you've gotten approval you need to manually add the "Family Controls (Distribution)" under Additional Capabilities for each of the bundleIdentifiers on [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) mentioned above. If you use Expo/EAS this has to be done only once, and after that provisioning will be handled automatically.

⚠️ If you don't do all the above, you will run into a lot of strange provisioning errors.

## Basic Example: Event Tracking Approach

Here's another example that focuses on tracking app usage with time thresholds:

```typescript
import * as ReactNativeDeviceActivity from "react-native-device-activity";

ReactNativeDeviceActivity.revokeAuthorization();

```

### Select Apps to track

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
- The activitySelection tokens can be particularly large (especially if you use includeEntireCategory flag), so you probably want to reference them through a familyActivitySelectionId instead of always passing the string token around. Most functions in this library accept a familyActivitySelectionId as well as the familyActivitySelection token directly.

### Time tracking

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

Depending on your use case (if you need different schedules for different days, for example) you might need multiple monitors. There's a hard limit on 20 monitors at the same time. Study the [DateComponents](https://developer.apple.com/documentation/foundation/datecomponents) object to model this to your use case.

### Block the shield

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

## Alternative Example: Blocking Apps for a Time Slot

This example shows how to implement a complete app blocking system on a given interval. The main principle is that you're configuring these apps to be blocked with FamilyControl API and then schedule when the shield should be shown with ActivityMonitor API. You're customizing the shield UI and actions with ShieldConfiguration and ShieldAction APIs.

```typescript
import { useEffect, useState } from 'react';
import { Alert, View, Button } from 'react-native';
import * as ReactNativeDeviceActivity from 'react-native-device-activity';

// Constants for identifying your selections, shields and scheduled activities
const SELECTION_ID = "evening_block_selection";
const SHIELD_CONFIG_ID = "evening_shield_config";
const ACTIVITY_NAME = "evening_block";

const AppBlocker = () => {
  // Step 1: Request authorization when component mounts
  useEffect(() => {
    ReactNativeDeviceActivity.requestAuthorization().then((status) => {
      console.info("Authorization status:", status);
      // You need to handle various status outcomes:
      // "authorized", "denied", "notDetermined", etc.
    });
  }, []);

  // Step 2: Manage the selection state of apps/websites to block
  const [currentFamilyActivitySelection, setCurrentFamilyActivitySelection] =
    useState<string | null>(null);

  // Step 3: Handle selection changes from the native selection UI
  const handleSelectionChange = (event) => {
    // The selection is a serialized string containing the user's app selections
    setCurrentFamilyActivitySelection(event.nativeEvent.familyActivitySelection);
  };

  // Step 4: Save the selection for use by the extension
  const saveSelection = () => {
    if (!currentFamilyActivitySelection) {
      Alert.alert("Error", "Please select at least one app to block");
      return;
    }

    // Store the selection with a consistent ID so the extension can access it
    ReactNativeDeviceActivity.setFamilyActivitySelectionId({
      id: SELECTION_ID,
      familyActivitySelection: currentFamilyActivitySelection
    });

    // Now configure the blocking schedule
    configureBlocking();
  };

  // Step 5: Configure the shield (blocking screen UI)
  const configureBlocking = () => {
    // Define how the blocking screen looks
    const shieldConfig = {
      title: "App Blocked",
      subtitle: "This app is currently unavailable",
      primaryButtonLabel: "OK",
      iconSystemName: "moon.stars.fill" // SF Symbols icon name
    };

    // Define what happens when users interact with the shield
    const shieldActions = {
      primary: {
        behavior: "close" // Just close the shield when OK is tapped
      }
    };

    // Apply the shield configuration
    ReactNativeDeviceActivity.updateShield(shieldConfig, shieldActions);

    // Configure what happens when the scheduled interval begins
    ReactNativeDeviceActivity.configureActions({
      activityName: ACTIVITY_NAME,
      callbackName: "intervalDidStart", // Called when the scheduled time begins
      actions: [{
        type: "blockSelection",
        familyActivitySelectionId: SELECTION_ID, // The stored selection ID
        shieldId: SHIELD_CONFIG_ID // The shield to show when blocked
      }]
    });

    // Configure what happens when the scheduled interval ends
    ReactNativeDeviceActivity.configureActions({
      activityName: ACTIVITY_NAME,
      callbackName: "intervalDidEnd", // Called when the scheduled time ends
      actions: [{
        type: "unblockSelection",
        familyActivitySelectionId: SELECTION_ID // Unblock the same selection
      }]
    });

    // Start the monitoring schedule
    startScheduledBlocking();
  };

  // Step 6: Define and start the blocking schedule
  const startScheduledBlocking = async () => {
    try {
      // Define when blocking should occur (7 PM to midnight daily)
      const schedule = {
        intervalStart: { hour: 19, minute: 0 }, // 7:00 PM
        intervalEnd: { hour: 23, minute: 59 }, // 11:59 PM
        repeats: true // Repeat this schedule daily
        // Optional: warningTime: { minutes: 5 } // Warn user 5 minutes before blocking starts
      };

      // For testing, you might want a shorter interval that starts soon:
      const testSchedule = {
        intervalStart: {
          hour: new Date().getHours(),
          minute: new Date().getMinutes(),
          second: (new Date().getSeconds() + 10) % 60, // +10 seconds from now
        },
        intervalEnd: {
          hour: new Date().getHours() + Math.floor((new Date().getMinutes() + 5) / 60),
          minute: (new Date().getMinutes() + 5) % 60, // +5 minutes from start
        },
        repeats: false, // One-time test
      };

      // Start monitoring with the schedule
      // The empty array is for event monitors (optional)
      await ReactNativeDeviceActivity.startMonitoring(
        ACTIVITY_NAME,
        schedule, // Use testSchedule for testing
        []
      );

      Alert.alert("Success", "Blocking schedule has been set up!");
    } catch (error) {
      console.error("Failed to start scheduled blocking:", error);
      Alert.alert("Error", "Failed to set up blocking schedule");
    }
  };

  return (
    <View style={{ flex: 1 }}>
      {/* Native selection view for choosing apps to block */}
      <ReactNativeDeviceActivity.DeviceActivitySelectionView
        onSelectionChange={handleSelectionChange}
        familyActivitySelection={currentFamilyActivitySelection}
        style={{
          width: "100%",
          flex: 1
        }}
      />

      {/* Save button */}
      <Button
        title="Save Selection and Schedule Blocking"
        onPress={saveSelection}
      />
    </View>
  );
};
```

### Key Concepts Explained

1. **Authorization**: The app must request permission to use Screen Time APIs.
2. **Selection**: Users choose which apps/websites to block via the native `DeviceActivitySelectionView`.
3. **Shield Configuration**: Defines how the blocking screen appears when users try to access blocked content.
4. **Action Configuration**: Defines what happens when the scheduled interval starts/ends.
5. **Scheduling**: Sets up when blocking should occur (e.g., evenings from 7 PM to midnight).

For a complete implementation, see the [example app](https://github.com/Kingstinct/react-native-device-activity/tree/main/example).

## API Reference (the list is not exhaustive yet please refer to the TypeScript types for the full list)

### Components

| Component                     | Props                                                                                                   | Description                                        |
| ----------------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `DeviceActivitySelectionView` | `familyActivitySelection`: string \| null<br>`onSelectionChange`: (event) => void<br>`style`: ViewStyle | Native component that renders the app selection UI |

### Hooks

| Hook                      | Returns                                                                                                                                                                              | Description                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------ |
| `useDeviceActivityPicker` | `currentFamilyActivitySelection`: string \| null<br>`isActivityPickerLoading`: boolean<br>`onSave`: () => void<br>`onCancel`: () => void<br>`handleSelectionChange`: (event) => void | Hook for managing the selection of apps to block |

### Functions

| Function                       | Parameters                                                                                      | Returns               | Description                                     |
| ------------------------------ | ----------------------------------------------------------------------------------------------- | --------------------- | ----------------------------------------------- |
| `requestAuthorization`         | None                                                                                            | Promise\<string\>     | Request Screen Time authorization               |
| `startMonitoring`              | `activityName`: string<br>`schedule`: DeviceActivitySchedule<br>`events`: DeviceActivityEvent[] | Promise\<void\>       | Start monitoring with given schedule            |
| `stopMonitoring`               | `activityName`: string                                                                          | Promise\<void\>       | Stop monitoring for given activity              |
| `setFamilyActivitySelectionId` | `{ id: string, familyActivitySelection: string }`                                               | void                  | Store a family activity selection with given ID |
| `updateShield`                 | `config`: ShieldConfiguration<br>`actions`: ShieldActions                                       | void                  | Update the shield UI and actions                |
| `configureActions`             | `{ activityName: string, callbackName: string, actions: Action[] }`                             | void                  | Configure actions for monitor events            |
| `getEvents`                    | None                                                                                            | DeviceActivityEvent[] | Get history of triggered events                 |
| `userDefaultsSet`              | `key`: string<br>`value`: any                                                                   | void                  | Store value in shared UserDefaults              |
| `userDefaultsGet`              | `key`: string                                                                                   | any                   | Retrieve value from shared UserDefaults         |

## Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide](https://github.com/expo/expo#contributing).

## Weird behaviors ⚠️

- Authorization changes outside app not captured
  When we've asked whether the user has authorized us to use screen time, and the state is changed outside the app, the native API doesn't update until the app restarts, i.e. this flow:

  1. Ask for current permission
  2. Change permission outside the app
  3. Ask for current permission again will return same as (1)
  4. **Workaround: restart the app**

- We can both request and revoke permissions as we like, and how many times we like, even when the user has denied permissions. This is very unlike most authorization flows on iOS.

- When calling `getAuthorizationStatus` it can sometimes return `notDetermined` even though the user has already made a choice, this comes with a delay. Workaround: keep polling the status for a while (`pollAuthorizationStatus` is a convenience function for this).

- The DeviceActivitySelectionView is prone to crashes, which is outside of our control. The best we can do is provide fallback views that allows the user to know what's happening and reload the view.

## Troubleshooting 📱

The Screen Time APIs are known to be very finnicky. Here are some things you can try to troubleshoot events not being reported:

- Disable Low Power Mode (mentioned by Apple Community Specialist [here](https://discussions.apple.com/thread/254808070)) 🪫
- Turn off/turn on app & website activity
- Disable/reenable sync between devices for screen time
- Restart device
- Make sure device is not low on storage (mentioned by Apple Community Specialist [here](https://discussions.apple.com/thread/254808070)) 💾
- Upgrade iOS version
- Content & Privacy Restrictions: If any restrictions are enabled under Screen Time's Content & Privacy Restrictions, ensure none are blocking your app.
- Reset all device settings
