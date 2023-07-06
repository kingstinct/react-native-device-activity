import React, { useEffect, useMemo } from "react";
import {
  Button,
  NativeSyntheticEvent,
  StyleSheet,
  Text,
  View,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";

const startMonitoring = (activitySelection: string) => {
  const timeLimitMinutes = 5;

  const totalEvents = (24 * 60) / timeLimitMinutes;

  const events: ReactNativeDeviceActivity.DeviceActivityEvent[] = [];

  for (let i = 0; i < totalEvents; i++) {
    const name = `${(i + 1) * timeLimitMinutes}_minutes_today`;
    events.push({
      eventName: name,
      familyActivitySelection: activitySelection,
      threshold: { minute: (i + 1) * timeLimitMinutes },
    });
  }

  ReactNativeDeviceActivity.startMonitoring(
    "Lifeline.AppLoggedTimeDaily",
    {
      intervalStart: { hour: 0, minute: 0, second: 0 },
      intervalEnd: { hour: 23, minute: 59, second: 59 },
      repeats: true,
      warningTime: { minute: timeLimitMinutes - 1, second: 30 },
    },
    events
  );
};

export default function App() {
  const [largestEvent, setLargestEvent] = React.useState<null | {
    minutesRegistered: number;
    registered: Date;
  }>(null);

  const [familyActivitySelection, setFamilyActivitySelection] = React.useState<
    string | null
  >(null);

  useEffect(() => {
    ReactNativeDeviceActivity.requestAuthorization();
    const listener = ReactNativeDeviceActivity.addSelectionChangeListener(
      (event) => {
        console.log(event);
      }
    );
    return () => {
      listener.remove();
    };
  }, []);

  return useMemo(
    () => (
      <View style={styles.container}>
        <Button
          title="Start monitoring"
          onPress={() => startMonitoring(familyActivitySelection!)}
        />

        <Button
          title="Stop monitoring"
          onPress={() => ReactNativeDeviceActivity.stopMonitoring()}
        />

        <Button
          title="Get events"
          onPress={() => {
            const events = ReactNativeDeviceActivity.getEvents();
            const eventsArrayWithDate = Object.keys(events).map((key) => {
              const timestamp = events[key];
              const registered = new Date(Math.round(timestamp));
              console.log(Math.round(timestamp));
              const minutesRegistered = parseInt(
                key.split("activity_event_last_called_")[1],
                10
              );
              return { event: key, registered, minutesRegistered };
            });

            const eventsOccurredToday = eventsArrayWithDate.filter((event) => {
              const today = new Date();
              return (
                event.registered.getDate() === today.getDate() &&
                event.registered.getMonth() === today.getMonth() &&
                event.registered.getFullYear() === today.getFullYear()
              );
            });

            const largestMinutesRegistered = eventsOccurredToday.reduce(
              (acc, event) => {
                return event.minutesRegistered > acc.minutesRegistered
                  ? event
                  : acc;
              },
              { minutesRegistered: 0, event: "none", registered: new Date() }
            );

            setLargestEvent(largestMinutesRegistered);
          }}
        />

        <ReactNativeDeviceActivity.ReactNativeDeviceActivityView
          style={{
            width: 200,
            height: 200,
            backgroundColor: "red",
            borderRadius: 10,
            borderWidth: 10,
            borderColor: "red",
          }}
          onSelectionChange={(
            event: NativeSyntheticEvent<{ familyActivitySelection: string }>
          ) => {
            if (
              event.nativeEvent.familyActivitySelection !==
              familyActivitySelection
            ) {
              setFamilyActivitySelection(
                event.nativeEvent.familyActivitySelection
              );
              alert(event.nativeEvent.familyActivitySelection);
            }
            console.log(event.nativeEvent.familyActivitySelection);
          }}
          familyActivitySelection={familyActivitySelection}
        >
          <View
            style={{ backgroundColor: "green", height: 100 }}
            pointerEvents="none"
          />
        </ReactNativeDeviceActivity.ReactNativeDeviceActivityView>

        <Text onLongPress={(e) => e.nativeEvent}>
          {ReactNativeDeviceActivity.hello()}
        </Text>
        <Text>{JSON.stringify(largestEvent, null, 2)}</Text>
      </View>
    ),
    [familyActivitySelection, largestEvent]
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
