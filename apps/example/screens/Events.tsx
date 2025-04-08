import React, { useCallback, useEffect, useState } from "react";
import {
  ScrollView,
  StyleSheet,
  Text,
  SafeAreaView,
  RefreshControl,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import { EventParsed } from "react-native-device-activity/src/ReactNativeDeviceActivity.types";

export function EventsTab() {
  const [events, setEvents] = React.useState<EventParsed[]>([]);

  const refreshEvents = useCallback(() => {
    const eventsParsed = ReactNativeDeviceActivity.getEvents();

    setEvents(
      eventsParsed.sort(
        (a, b) => b.lastCalledAt.valueOf() - a.lastCalledAt.valueOf(),
      ),
    );
  }, []);

  useEffect(() => {
    const listener = ReactNativeDeviceActivity.onDeviceActivityMonitorEvent(
      () => {
        refreshEvents();
      },
    );
    refreshEvents();
    return () => {
      listener.remove();
    };
  }, [refreshEvents]);

  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    refreshEvents();
    setRefreshing(false);
  }, [refreshEvents]);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView
        style={styles.container}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <Text>{JSON.stringify(events, null, 2)}</Text>
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
