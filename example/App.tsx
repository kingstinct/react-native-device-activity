import React, { useEffect } from "react";
import { Button, StyleSheet, Text, View } from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";

type EventsLookup = Record<string, number>;

export default function App() {
  const [largestEvent, setLargestEvent] = React.useState<null | {
    minutesRegistered: number;
    registered: Date;
  }>(null);
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
  return (
    <View style={styles.container}>
      <Button
        title="Start monitoring"
        onPress={() => ReactNativeDeviceActivity.startMonitoring()}
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
        name="hello"
        style={{ width: 200, height: 200, backgroundColor: "red" }}
      >
        <View
          style={{ backgroundColor: "yellow", height: 100 }}
          pointerEvents="none"
        />
      </ReactNativeDeviceActivity.ReactNativeDeviceActivityView>

      <Text>{ReactNativeDeviceActivity.hello()}</Text>
      <Text>{JSON.stringify(largestEvent, null, 2)}</Text>
    </View>
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
