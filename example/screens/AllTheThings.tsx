import * as FileSystem from "expo-file-system";
import * as Notifications from "expo-notifications";
import React, { useCallback, useEffect, useState } from "react";
import {
  Button,
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  Linking,
  View,
  Alert,
  SafeAreaView,
  TextInput,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import {
  AuthorizationStatus,
  DeviceActivityEvent,
  EventParsed,
  UIBlurEffectStyle,
} from "react-native-device-activity/ReactNativeDeviceActivity.types";

// const initialMinutes = 1;
// const postponeMinutes = 60;
const trackEveryXMinutes = 1;

export function requestPermissionsAsync() {
  return Notifications.requestPermissionsAsync({
    ios: {
      allowAlert: true,
      allowBadge: true,
      allowSound: true,
    },
  });
}

/* console.log(
  JSON.stringify(
    ReactNativeDeviceActivity.userDefaultsGet(
      "familyActivitySelectionToActivityNameMap",
    ),
    null,
    2,
  ),
);*/

/*console.log("bundleDirectory", FileSystem.bundleDirectory);
console.log("cacheDirectory", FileSystem.cacheDirectory);
console.log("documentDirectory", FileSystem.documentDirectory);*/

const readDirectoryRecursively = async (path: string) => {
  console.log("directory", path);
  const files = await FileSystem.readDirectoryAsync(path);

  if (files.length > 0) {
    for (const file of files) {
      const fullPath = path + "/" + file;
      if ((await FileSystem.getInfoAsync(fullPath)).isDirectory) {
        await readDirectoryRecursively(fullPath);
      } else {
        console.log(fullPath);
      }
    }
  }
};

const appGroupFileDirectory =
  ReactNativeDeviceActivity.getAppGroupFileDirectory();

readDirectoryRecursively(appGroupFileDirectory);
// readDirectoryRecursively(FileSystem.bundleDirectory ?? "");
// readDirectoryRecursively(FileSystem.cacheDirectory ?? "");
readDirectoryRecursively(FileSystem.documentDirectory ?? "");

/*void FileSystem.makeDirectoryAsync(appGroupFileDirectory + "Documents", {
  intermediates: false,
});*/

const downloadAndMoveIcon = async (
  url: string,
  iconAppGroupRelativePath: string,
) => {
  const filename = iconAppGroupRelativePath.split("/").pop();
  const result = await FileSystem.downloadAsync(
    url,
    FileSystem.cacheDirectory! + filename,
    {
      cache: true,
    },
  );
  await ReactNativeDeviceActivity.moveFile(
    result.uri,
    appGroupFileDirectory + iconAppGroupRelativePath,
    true,
  );
};

downloadAndMoveIcon(
  "https://s3-alpha-sig.figma.com/img/c35b/b92b/25ecc68b7de92b14b9aa5fa9ddf4b476?Expires=1733097600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=O20vLYM4Tl5AVkxGnfQznu9DV3HLDhV26T2NUT6EDttxEeKkR4rZPnHJZk4ts89ofSfbtLrIkOamUld7r5DL0jYSGxzy94uq0MlVWCey54n2htYvw74BWHzYGpzHaX24lGc-ETQRI-LTYldGKPE~h6Q7aPxB2iUefcPnHL8a4BYCtYoHaqz11m3gAZaQymrn~lRrqy2K9ld3XSUEz7otvCgl4GXMarE39r~8bsJEmye5oNBAKJ4OZHMDovKhSO0kF3LLmJKXIICAOCkHFHV-2uBT~kl3oNV3B7j5Tx3Jc23QrSTLEIcrifZWmrDKgJkDmsUcfyxqZ202XU723mRSxg__",
  "my-awesome-image.png",
);

// gets run on reload, so easy to play around with
void ReactNativeDeviceActivity.updateShieldConfiguration(
  {
    backgroundBlurStyle: UIBlurEffectStyle.prominent,
    title:
      "{applicationOrDomainDisplayName} blocked by react-native-device-activity",
    subtitle: "You have reached your limit! {activityName}",
    primaryButtonLabel: "Give me 5 more minutes",
    secondaryButtonLabel: "Close",
    //icon: appGroupFileDirectory + "/kingstinct.png",
    iconAppGroupRelativePath: "my-awesome-image.png",
    titleColor: {
      red: 255,
      green: 0.329 * 255,
      blue: 0,
      alpha: 1,
    },
    subtitleColor: {
      red: 255,
      green: 0.329 * 255,
      blue: 0,
      alpha: 1,
    },
    primaryButtonBackgroundColor: {
      red: 255,
      green: 0.329 * 255,
      blue: 0,
      alpha: 1,
    },
  },
  {
    primary: {
      type: "unblockAll",
      behavior: "defer",
    },
    secondary: {
      type: "dismiss",
      behavior: "close",
    },
  },
);

const activityName = "Instagram3";

const potentialMaxEvents = Math.floor((60 * 24) / trackEveryXMinutes);

const startMonitoring = async (activitySelection: string) => {
  await requestPermissionsAsync();

  // ReactNativeDeviceActivity.updateFamilyActivitySelectionToActivityNameMap({
  //   activityName,
  //   familyActivitySelection: activitySelection,
  // });

  const events: DeviceActivityEvent[] = [
    /*  {
      eventName: `minutes_reached_${initialMinutes}`,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes },
    },
    {
      eventName: `minutes_reached_${initialMinutes}_override`,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes, nanosecond: 1 },
    },*/
  ];

  for (let i = 1; i < potentialMaxEvents; i++) {
    const minutesReached = i * trackEveryXMinutes;
    const eventName = `minutes_reached_${minutesReached}`;
    const event: DeviceActivityEvent = {
      eventName,
      familyActivitySelection: activitySelection,
      threshold: { minute: minutesReached },
      includesPastActivity: false,
    };

    const overrideEventName = `minutes_reached_${minutesReached}_override`;
    const overrideEvent: DeviceActivityEvent = {
      eventName: overrideEventName,
      familyActivitySelection: activitySelection,
      threshold: { minute: minutesReached, nanosecond: 1 },
    };

    ReactNativeDeviceActivity.configureActions({
      activityName,
      callbackName: "eventDidReachThreshold",
      eventName: overrideEventName,
      actions: [
        {
          type: "sendNotification",
          payload: {
            title: "override!! {activityName}!",
            body: "You have reached {eventName} minutes!",
          },
        },
      ],
    });

    ReactNativeDeviceActivity.configureActions({
      activityName,
      callbackName: "eventDidReachThreshold",
      eventName,
      actions: [
        /*{
          type: "blockSelection",
          familyActivitySelection: activitySelection,
          shieldActions: {
            primary: { type: "unblockAll", behavior: "defer" },
            secondary: { type: "dismiss", behavior: "close" },
          },
          shieldConfiguration: {
            backgroundBlurStyle: UIBlurEffectStyle.prominent,
            title:
              "{applicationOrDomainDisplayName} Blocked by react-native-device-activity",
            subtitle: "You have reached your limit! {activityName}",
            primaryButtonLabel: "Give me 5 more minutes",
            secondaryButtonLabel: "Close",
            titleColor: {
              red: 255,
              green: 0.329 * 255,
              blue: 0,
              alpha: 1,
            },
            subtitleColor: {
              red: 255,
              green: 0.329 * 255,
              blue: 0,
              alpha: 1,
            },
            primaryButtonBackgroundColor: {
              red: 255,
              green: 0.329 * 255,
              blue: 0,
              alpha: 1,
            },
          },
        },*/
        {
          type: "sendHttpRequest",
          url: "https://webhook.site/df7583bc-fba5-4080-8a04-7417bccb2030",
          options: {
            method: "POST",
            body: {
              activityName,
              eventName,
              minutesReached,
            },
          },
        },
        {
          type: "sendNotification",
          payload: {
            title: "{activityName}!",
            body: "You have reached {eventName} minutes!",
          },
        },
        {
          type: "openApp",
        },
      ],
    });

    events.push(overrideEvent);

    events.push(event);
  }

  ReactNativeDeviceActivity.startMonitoring(
    activityName,
    {
      // warningTime: { minute: 1 },
      intervalStart: { hour: 0, minute: 0, second: 0 },
      intervalEnd: { hour: 23, minute: 59, second: 59 },
      repeats: false,
    },
    events,
  );
};

const authorizationStatusMap = {
  [AuthorizationStatus.approved]: "approved",
  [AuthorizationStatus.denied]: "denied",
  [AuthorizationStatus.notDetermined]: "notDetermined",
};

export function AllTheThings() {
  const [events, setEvents] = React.useState<EventParsed[]>([]);
  const [shieldTitle, setShieldTitle] = React.useState<string>("");
  const [activities, setActivities] = React.useState<string[]>([]);
  const [authorizationStatus, setAuthorizationStatus] =
    React.useState<AuthorizationStatus | null>(null);

  /*console.log(
    JSON.stringify(
      ReactNativeDeviceActivity.userDefaultsGet("shieldActions"),
      null,
      2,
    ),
  );*/

  const [familyActivitySelection, setFamilyActivitySelection] = React.useState<
    string | null
  >(null);

  useEffect(() => {
    const status = ReactNativeDeviceActivity.getAuthorizationStatus();
    console.log("authorization status", authorizationStatusMap[status]);
    setAuthorizationStatus(status);
  }, []);

  const refreshEvents = useCallback(() => {
    const eventsParsed = ReactNativeDeviceActivity.getEvents();

    setEvents(eventsParsed);
  }, []);

  const requestAuthorization = useCallback(async () => {
    if (authorizationStatus === AuthorizationStatus.notDetermined) {
      const status = await ReactNativeDeviceActivity.requestAuthorization();
      setAuthorizationStatus(status);
    } else if (authorizationStatus === AuthorizationStatus.denied) {
      Alert.alert(
        "You didn't grant access",
        "Please go to settings and enable it",
        [
          {
            text: "Open settings",
            onPress: () => Linking.openSettings(),
          },
          {
            text: "Cancel",
            style: "cancel",
          },
        ],
      );
    } else {
      const status = await ReactNativeDeviceActivity.revokeAuthorization();
      setAuthorizationStatus(status);
    }
  }, [authorizationStatus]);

  useEffect(() => {
    const listener = ReactNativeDeviceActivity.addEventReceivedListener(
      (event) => {
        if (event.callbackName === "eventDidReachThreshold") refreshEvents();
      },
    );
    return () => {
      listener.remove();
    };
  }, [refreshEvents]);

  const [isShieldActive, setIsShieldActive] = useState(false);
  const [isShieldActiveWithSelection, setIsShieldActiveWithSelection] =
    useState(false);

  const refreshIsShieldActive = useCallback(() => {
    setIsShieldActive(ReactNativeDeviceActivity.isShieldActive());
    if (familyActivitySelection) {
      setIsShieldActiveWithSelection(
        ReactNativeDeviceActivity.isShieldActiveWithSelection(
          familyActivitySelection,
        ),
      );
    } else {
      setIsShieldActiveWithSelection(false);
    }
  }, [familyActivitySelection]);

  useEffect(() => {
    ReactNativeDeviceActivity.registerManagedStoreListener(
      ({ activityName }) => {
        console.log("activityName", activityName);
      },
    );
    refreshIsShieldActive();
  }, [familyActivitySelection, refreshIsShieldActive]);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView style={styles.container}>
        <Text>
          Authorization status:
          {authorizationStatus !== null
            ? authorizationStatusMap[authorizationStatus]
            : "unknown"}
        </Text>

        <Text>
          Shield active:
          {isShieldActive ? "✅" : "❌"}
        </Text>

        <Text>
          Shielding current selection:
          {isShieldActiveWithSelection ? "✅" : "❌"}
        </Text>

        <Button
          title={
            authorizationStatus === AuthorizationStatus.approved
              ? "Revoke authorization"
              : "Request authorization"
          }
          onPress={requestAuthorization}
        />

        <Button
          title="Start monitoring"
          disabled={!familyActivitySelection}
          onPress={() => startMonitoring(familyActivitySelection!)}
        />

        <Button
          title="Stop monitoring"
          disabled={!familyActivitySelection}
          onPress={() => ReactNativeDeviceActivity.stopMonitoring()}
        />

        <Button
          title="Get activities"
          onPress={() =>
            setActivities(ReactNativeDeviceActivity.getActivities())
          }
        />

        <Button title="Get events" onPress={refreshEvents} />

        <Button
          title="Block all apps"
          onPress={async () => {
            await ReactNativeDeviceActivity.blockApps(
              familyActivitySelection ?? undefined,
            );
            refreshIsShieldActive();
          }}
        />
        <Button
          title="Unblock all apps"
          onPress={async () => {
            await ReactNativeDeviceActivity.unblockApps();
            refreshIsShieldActive();
          }}
        />

        <TextInput
          placeholder="Enter shield title"
          onChangeText={(text) => setShieldTitle(text)}
          value={shieldTitle}
          onSubmitEditing={() =>
            ReactNativeDeviceActivity.updateShieldConfiguration(
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
                  type: "unblockAll",
                  behavior: "defer",
                },
                secondary: {
                  type: "dismiss",
                  behavior: "close",
                },
              },
            )
          }
        />

        <ReactNativeDeviceActivity.DeviceActivitySelectionView
          style={{
            width: 200,
            height: 40,
            alignSelf: "center",
            borderRadius: 20,
            borderWidth: 10,
            borderColor: "rgb(213,85,37)",
          }}
          headerText="a header text!"
          footerText="a footer text!"
          onSelectionChange={(
            event: NativeSyntheticEvent<{ familyActivitySelection: string }>,
          ) => {
            if (
              event.nativeEvent.familyActivitySelection !==
              familyActivitySelection
            ) {
              setFamilyActivitySelection(
                event.nativeEvent.familyActivitySelection,
              );
            }
          }}
          familyActivitySelection={familyActivitySelection}
        >
          <View
            pointerEvents="none"
            style={{
              backgroundColor: "rgb(213,85,37)",
              flex: 1,
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Text style={{ color: "white" }}>Select apps</Text>
          </View>
        </ReactNativeDeviceActivity.DeviceActivitySelectionView>
        <Text>{JSON.stringify(events, null, 2)}</Text>
        <Text>{JSON.stringify(activities, null, 2)}</Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    margin: 10,
    flex: 1,
    backgroundColor: "#fff",
  },
});
