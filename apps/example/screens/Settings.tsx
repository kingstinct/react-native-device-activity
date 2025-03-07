import React from "react";
import { Button, ScrollView, StyleSheet, SafeAreaView } from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";

export function Settings() {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView style={styles.container}>
        <Button
          title="Clear user defaults"
          onPress={() => ReactNativeDeviceActivity.userDefaultsClear()}
        />
        <Button
          title="Stop monitoring"
          onPress={() => ReactNativeDeviceActivity.stopMonitoring()}
        />
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
