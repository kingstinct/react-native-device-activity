import React, { useCallback, useEffect, useState } from "react";
import {
  ScrollView,
  StyleSheet,
  Linking,
  Alert,
  SafeAreaView,
  View,
  RefreshControl,
  AppState,
} from "react-native";
import {
  AuthorizationStatus,
  cleanUpAfterActivity,
  revokeAuthorization,
  stopMonitoring,
  useActivities,
  useAuthorizationStatus,
  AuthorizationStatusType,
  requestAuthorization,
} from "react-native-device-activity";
import { Button, Modal, Text, Title } from "react-native-paper";

import { CreateActivity } from "../components/CreateActivity";

const authorizationStatusMap: Record<AuthorizationStatusType, string> = {
  [AuthorizationStatus.approved]: "approved",
  [AuthorizationStatus.denied]: "denied",
  [AuthorizationStatus.notDetermined]: "notDetermined",
};

export function SimpleTab() {
  const authorizationStatus = useAuthorizationStatus();

  const [activities, refreshActivities] = useActivities();

  const onPressRequestCallback = useCallback(async () => {
    if (authorizationStatus === AuthorizationStatus.notDetermined) {
      await requestAuthorization();
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
      await revokeAuthorization();
    }
  }, [authorizationStatus]);

  const [showCreateActivityPopup, setShowCreateActivityPopup] = useState(false);

  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    const subscription = AppState.addEventListener("change", (state) => {
      if (state === "active") {
        refreshActivities();
      }
    });
    return () => subscription.remove();
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    refreshActivities();
    setRefreshing(false);
  }, [refreshActivities]);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView
        style={styles.container}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
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

          <Button onPress={onPressRequestCallback} mode="contained">
            {authorizationStatus === AuthorizationStatus.approved
              ? "Revoke authorization"
              : "Request authorization"}
          </Button>
        </View>
        <Title>Activities</Title>
        {activities.map((activity) => (
          <View
            key={activity}
            style={{
              flexDirection: "row",
              alignItems: "center",
              justifyContent: "space-between",
              marginVertical: 10,
            }}
          >
            <Text>{activity}</Text>
            <Button
              mode="contained"
              onPress={() => {
                cleanUpAfterActivity(activity);
                stopMonitoring([activity]);
                refreshActivities();
              }}
            >
              Stop
            </Button>
          </View>
        ))}
        <Button
          onPress={() => {
            setShowCreateActivityPopup(true);
          }}
        >
          Create Activity
        </Button>
      </ScrollView>
      <Modal
        visible={showCreateActivityPopup}
        onDismiss={() => setShowCreateActivityPopup(false)}
        contentContainerStyle={{ backgroundColor: "white", margin: 10 }}
      >
        <CreateActivity
          onDismiss={() => {
            setShowCreateActivityPopup(false);
            refreshActivities();
          }}
        />
      </Modal>
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
