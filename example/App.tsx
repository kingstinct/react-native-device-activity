import React, { useCallback, useEffect, useMemo } from "react";
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

const initialMinutes = 2;
const postponeMinutes = 1;

const potentialMaxEvents = Math.floor(
  (60 * 24 - initialMinutes) / postponeMinutes,
);

const startMonitoring = (activitySelection: string) => {
  const events: DeviceActivityEvent[] = [
    {
      eventName: `minutes_reached_${initialMinutes}`,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes },
    },
  ];

  for (let i = 0; i < potentialMaxEvents; i++) {
    const eventName = `minutes_reached_${initialMinutes + i * postponeMinutes}`;
    const event: DeviceActivityEvent = {
      eventName,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes + i * postponeMinutes },
    };
    events.push(event);
  }

  ReactNativeDeviceActivity.startMonitoring(
    "Goal1",
    {
      warningTime: { minute: 1 },
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

export default function App() {
  const [events, setEvents] = React.useState<EventParsed[]>([]);
  const [shieldTitle, setShieldTitle] = React.useState<string>("");
  const [activities, setActivities] = React.useState<string[]>([]);
  const [authorizationStatus, setAuthorizationStatus] =
    React.useState<AuthorizationStatus | null>(null);

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

    console.log("eventsParsed", eventsParsed);
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
        console.log("got event, refreshing events!", event);
        refreshEvents();
      },
    );
    return () => {
      listener.remove();
    };
  }, [refreshEvents]);

  return useMemo(
    () => (
      <SafeAreaView style={{ flex: 1 }}>
        <ScrollView style={styles.container}>
          <Text>
            Authorization status:
            {authorizationStatus !== null
              ? authorizationStatusMap[authorizationStatus]
              : "unknown"}
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
            onPress={ReactNativeDeviceActivity.blockAllApps}
          />
          <Button
            title="Unblock all apps"
            onPress={ReactNativeDeviceActivity.unblockAllApps}
          />

          <TextInput
            placeholder="Enter shield title"
            onChangeText={(text) => setShieldTitle(text)}
            value={shieldTitle}
            onSubmitEditing={() =>
              ReactNativeDeviceActivity.updateShieldConfiguration({
                title: shieldTitle,
                backgroundBlurStyle: UIBlurEffectStyle.systemMaterialDark,
                // backgroundColor: null,
                titleColor: {
                  red: 1,
                  green: 0,
                  blue: 0,
                },
                subtitle: "subtitle",
                subtitleColor: {
                  red: Math.random() * 1,
                  green: Math.random() * 1,
                  blue: Math.random() * 1,
                },
                primaryButtonBackgroundColor: {
                  red: Math.random() * 1,
                  green: Math.random() * 1,
                  blue: Math.random() * 1,
                },
                primaryButtonLabelColor: {
                  red: Math.random() * 1,
                  green: Math.random() * 1,
                  blue: Math.random() * 1,
                },
                secondaryButtonLabelColor: {
                  red: Math.random() * 1,
                  green: Math.random() * 1,
                  blue: Math.random() * 1,
                },
              })
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
              console.log("event.nativeEvent", event.nativeEvent);
              if (
                event.nativeEvent.familyActivitySelection !==
                familyActivitySelection
              ) {
                setFamilyActivitySelection(
                  event.nativeEvent.familyActivitySelection,
                );

                // alert(event.nativeEvent.familyActivitySelection);
              }
              // console.log(event.nativeEvent.familyActivitySelection);
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
    ),
    [familyActivitySelection, events, authorizationStatus, shieldTitle],
  );
}

const styles = StyleSheet.create({
  container: {
    margin: 10,
    flex: 1,
    backgroundColor: "#fff",
  },
});
