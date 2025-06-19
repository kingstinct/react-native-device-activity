import * as FileSystem from "expo-file-system";
import * as Notifications from "expo-notifications";
import React, { useCallback, useEffect, useState } from "react";
import {
  Button,
  ScrollView,
  StyleSheet,
  Text,
  Linking,
  View,
  Alert,
  SafeAreaView,
  TextInput,
  Pressable,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import {
  AuthorizationStatus,
  EventParsed,
  UIBlurEffectStyle,
} from "react-native-device-activity";

import { ActivityPickerPersisted } from "../components/ActivityPicker";

// const initialMinutes = 1;
// const postponeMinutes = 60;
const trackEveryXMinutes = 1;

const selectionId = "some-id-3";

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
      "familyActivitySelectionIds",
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
    React.useState<ReactNativeDeviceActivity.AuthorizationStatusType | null>(
      null,
    );

  /*console.log(
    JSON.stringify(
      ReactNativeDeviceActivity.userDefaultsGet("shieldActions"),
      null,
      2,
    ),
  );*/

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
      await ReactNativeDeviceActivity.requestAuthorization();
      const status = ReactNativeDeviceActivity.getAuthorizationStatus();
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
    const listener = ReactNativeDeviceActivity.onDeviceActivityMonitorEvent(
      (event) => {
        refreshEvents();
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

    const familyActivitySelection =
      ReactNativeDeviceActivity.getFamilyActivitySelectionId(selectionId);

    if (familyActivitySelection) {
      setIsShieldActiveWithSelection(
        ReactNativeDeviceActivity.isSubsetOf(
          {
            activitySelectionToken: familyActivitySelection,
          },
          {
            currentBlocklist: true,
          },
        ),
      );
    }
  }, []);

  const [pickerVisible, setPickerVisible] = useState(false);

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
          // onPress={() => startMonitoring(familyActivitySelection!)}
        />

        <Button
          title="Stop monitoring"
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
            ReactNativeDeviceActivity.enableBlockAllMode();
            refreshIsShieldActive();
          }}
        />

        <Button
          title="Block selected apps"
          onPress={async () => {
            ReactNativeDeviceActivity.blockSelection({
              activitySelectionId: selectionId,
            });
            refreshIsShieldActive();
          }}
        />
        <Button
          title="Unblock all apps"
          onPress={async () => {
            ReactNativeDeviceActivity.disableBlockAllMode();
            refreshIsShieldActive();
          }}
        />

        <Button
          title="Unblock selected apps"
          onPress={async () => {
            ReactNativeDeviceActivity.unblockSelection({
              activitySelectionId: selectionId,
            });
            refreshIsShieldActive();
          }}
        />

        <Button
          title="Test sneakpeak"
          onPress={() => {
            /*ReactNativeDeviceActivity.configureActions({
              activityName: "sneek-peak",
              callbackName: "intervalDidEnd",
              actions: [
                {
                  type: "sendNotification",
                  payload: {
                    title: "sneek-peak ended!!!",
                    body: "You have reached the end of the sneek-peak!",
                  },
                },
                {
                  type: "enableBlockAllMode",
                },
                {
                  type: "clearWhitelistAndUpdateBlock",
                },
              ],
            });*/

            ReactNativeDeviceActivity.configureActions({
              activityName: "sneekpeak",
              callbackName: "intervalDidStart",
              actions: [
                {
                  type: "sendNotification",
                  payload: {
                    title: "sneek-peak ended!!!",
                    body: "You have reached the end of the sneek-peak!",
                  },
                },
                {
                  type: "enableBlockAllMode",
                },
                {
                  type: "clearWhitelistAndUpdateBlock",
                },
                {
                  type: "stopMonitoring",
                  activityNames: ["sneekpeak"],
                }
              ],
            });
            ReactNativeDeviceActivity.updateShield(
              {
                title: "take a sneekpeak!",
                primaryButtonLabel: "do it now!",
              },
              {
                primary: {
                  behavior: "defer",
                  actions: [
                    {
                      type: "disableBlockAllMode",
                    },
                    {
                      type: "clearWhitelistAndUpdateBlock",
                    },
                    {
                      type: "startMonitoring",
                      activityName: "sneekpeak",
                      intervalStartDelayMs: 10000,
                      intervalEndDelayMs: 60 * 15 * 1000 + 10000,
                      deviceActivityEvents: [],
                    },
                  ],
                },
              },
            );
            console.log("done!");
            console.log(ReactNativeDeviceActivity.getEvents())
          }}
        />

        <TextInput
          placeholder="Enter shield title"
          onChangeText={(text) => setShieldTitle(text)}
          value={shieldTitle}
          onSubmitEditing={() =>
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
          }
        />

        <Pressable
          onPress={() => {
            setPickerVisible(true);
          }}
        >
          <View
            style={{
              backgroundColor: "rgb(213,85,37)",
              flex: 1,
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Text style={{ color: "white" }}>Select apps</Text>
          </View>
        </Pressable>

        <ActivityPickerPersisted
          familyActivitySelectionId={selectionId}
          visible={pickerVisible}
          onDismiss={() => setPickerVisible(false)}
          onSelectionChange={(event) => {
            console.log("selection changed", event.nativeEvent);
            console.log(
              JSON.stringify(
                ReactNativeDeviceActivity.userDefaultsGet(
                  "familyActivitySelectionIds",
                ),
                null,
                2,
              ),
            );
          }}
          onReload={() => {
            setPickerVisible(false);
            setTimeout(() => {
              setPickerVisible(true);
            }, 100);
          }}
        />
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
