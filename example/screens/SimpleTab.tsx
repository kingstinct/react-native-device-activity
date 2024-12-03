import React, { useCallback, useEffect } from "react";
import {
  ScrollView,
  StyleSheet,
  Linking,
  Alert,
  SafeAreaView,
  View,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import { AuthorizationStatus } from "react-native-device-activity/ReactNativeDeviceActivity.types";
import { Button, Text, Title } from "react-native-paper";

const authorizationStatusMap = {
  [AuthorizationStatus.approved]: "approved",
  [AuthorizationStatus.denied]: "denied",
  [AuthorizationStatus.notDetermined]: "notDetermined",
};

export function SimpleTab() {
  const authorizationStatus =
    ReactNativeDeviceActivity.useAuthorizationStatus();

  const requestAuthorization = useCallback(async () => {
    if (authorizationStatus === AuthorizationStatus.notDetermined) {
      await ReactNativeDeviceActivity.requestAuthorization();
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
      await ReactNativeDeviceActivity.revokeAuthorization();
    }
  }, [authorizationStatus]);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView style={styles.container}>
        <Title>Authorization</Title>
        <View
          style={{
            flexDirection: "row",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <Text>
            {authorizationStatus === AuthorizationStatus.approved
              ? "✅ "
              : authorizationStatus === AuthorizationStatus.denied
                ? "❌ "
                : "❓ "}
          </Text>
          <Text style={{ flex: 1 }}>
            {authorizationStatusMap[authorizationStatus]}
          </Text>

          <Button onPress={requestAuthorization} mode="contained">
            {authorizationStatus === AuthorizationStatus.approved
              ? "Revoke authorization"
              : "Request authorization"}
          </Button>
        </View>
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
