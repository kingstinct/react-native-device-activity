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
  ShieldConfiguration,
  UIBlurEffectStyle,
} from "react-native-device-activity/ReactNativeDeviceActivity.types";

const initialMinutes = 1;
const postponeMinutes = 60;

type ShieldActionType = "unblockAll" | "dismiss";

type ShieldAction = {
  type: ShieldActionType;
  behavior: "close" | "defer";
};

type ShieldActions = {
  primary: ShieldAction;
  secondary: ShieldAction;
};

type Action = {
  type: "block";
  familyActivitySelection: string;
  shieldConfiguration: ShieldConfiguration;
  shieldActions: ShieldActions;
};

console.log(
  JSON.stringify(
    ReactNativeDeviceActivity.userDefaultsGet(
      "familyActivitySelectionToActivityNameMap",
    ),
    null,
    2,
  ),
);

// gets run on reload, so easy to play around with
void ReactNativeDeviceActivity.updateShieldConfiguration({
  backgroundBlurStyle: UIBlurEffectStyle.prominent,
  title: "{applicationOrDomainDisplayName} blocked by Zabit",
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
});

type CallbackName =
  | "warningTime"
  | "intervalStart"
  | "intervalEnd"
  | "eventDidReachThreshold";

const activityName = "Goal4";

const configureActions = ({
  activityName,
  callbackName,
  actions,
  eventName,
}: {
  activityName: string;
  callbackName: CallbackName;
  actions: Action[];
  eventName?: string;
}) => {
  const key = eventName
    ? `actions_for_${activityName}_${callbackName}_${eventName}`
    : `actions_for_${activityName}_${callbackName}`;

  ReactNativeDeviceActivity.userDefaultsSet(key, actions);
};

const updateFamilyActivitySelectionToActivityNameMap = ({
  activityName,
  familyActivitySelection,
}: {
  activityName: string;
  familyActivitySelection: string;
}) => {
  const previousValue =
    (ReactNativeDeviceActivity.userDefaultsGet(
      "familyActivitySelectionToActivityNameMap",
    ) as Record<string, string>) ?? {};

  ReactNativeDeviceActivity.userDefaultsSet(
    "familyActivitySelectionToActivityNameMap",
    {
      ...previousValue,
      [activityName]: familyActivitySelection,
    },
  );
};

const potentialMaxEvents = Math.floor(
  (60 * 24 - initialMinutes) / postponeMinutes,
);

const startMonitoring = (activitySelection: string) => {
  updateFamilyActivitySelectionToActivityNameMap({
    activityName,
    familyActivitySelection: activitySelection,
  });

  const events: DeviceActivityEvent[] = [
    {
      eventName: `minutes_reached_${initialMinutes}`,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes },
    },
    {
      eventName: `minutes_reached_${initialMinutes}_override`,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes, second: 1 },
    },
  ];

  for (let i = 1; i < potentialMaxEvents; i++) {
    const eventName = `minutes_reached_${initialMinutes + i * postponeMinutes}`;
    const event: DeviceActivityEvent = {
      eventName,
      familyActivitySelection: activitySelection,
      threshold: { minute: initialMinutes + i * postponeMinutes },
      includesPastActivity: false,
    };
    events.push(event);
  }

  console.log("events", events);

  configureActions({
    activityName,
    callbackName: "eventDidReachThreshold",
    eventName: "minutes_reached_1",
    actions: [
      {
        type: "block",
        familyActivitySelection: activitySelection,
        shieldActions: {
          primary: { type: "unblockAll", behavior: "defer" },
          secondary: { type: "dismiss", behavior: "close" },
        },
        shieldConfiguration: {
          backgroundBlurStyle: UIBlurEffectStyle.prominent,
          title: "{applicationOrDomainDisplayName} Blocked by Zabit",
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
      },
    ],
  });

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

export default function App() {
  const [events, setEvents] = React.useState<EventParsed[]>([]);
  const [shieldTitle, setShieldTitle] = React.useState<string>("");
  const [activities, setActivities] = React.useState<string[]>([]);
  const [authorizationStatus, setAuthorizationStatus] =
    React.useState<AuthorizationStatus | null>(null);

  console.log(
    JSON.stringify(
      ReactNativeDeviceActivity.userDefaultsGet("shieldActions"),
      null,
      2,
    ),
  );

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
