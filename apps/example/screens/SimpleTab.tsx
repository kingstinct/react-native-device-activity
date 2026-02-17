import React, { useCallback, useEffect, useState } from "react";
import {
  NativeSyntheticEvent,
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
  ActivitySelectionMetadata,
} from "react-native-device-activity";
import { Button, Modal, Text, Title } from "react-native-paper";

import { ActivityPickerPersisted } from "../components/ActivityPicker";
import { CreateActivity } from "../components/CreateActivity";

const authorizationStatusMap: Record<AuthorizationStatusType, string> = {
  [AuthorizationStatus.approved]: "approved",
  [AuthorizationStatus.denied]: "denied",
  [AuthorizationStatus.notDetermined]: "notDetermined",
};

export function SimpleTab() {
  const authorizationStatus = useAuthorizationStatus();

  const [activities, refreshActivities] = useActivities();

  const onPressRequestCallback = useCallback(
    async (forIndividualOrChild: "individual" | "child" = "individual") => {
      if (authorizationStatus === AuthorizationStatus.notDetermined) {
        try {
          await requestAuthorization(forIndividualOrChild);
        } catch (e) {
          Alert.alert("Error requesting authorization", (e as Error).message);
          console.log("Error requesting authorization", e);
        }
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
    },
    [authorizationStatus],
  );

  const [showCreateActivityPopup, setShowCreateActivityPopup] = useState(false);

  const [pickerNative, setPickerNative] = useState(false);
  const [pickerCustomModal, setPickerCustomModal] = useState(false);

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
          <View style={{ gap: 10 }}>
            <Button onPress={() => onPressRequestCallback()} mode="contained">
              {authorizationStatus === AuthorizationStatus.approved
                ? "Revoke authorization"
                : "Request authorization"}
            </Button>
            <Button
              onPress={() => onPressRequestCallback("child")}
              mode="contained"
            >
              {authorizationStatus === AuthorizationStatus.approved
                ? "Revoke child authorization"
                : "Request child authorization"}
            </Button>
          </View>
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

        <Title style={{ marginTop: 20 }}>Picker Views</Title>
        <Button
          mode="outlined"
          onPress={() => setPickerNative(true)}
          style={{ marginVertical: 4 }}
        >
          Sheet View (native iOS)
        </Button>
        <Button
          mode="outlined"
          onPress={() => setPickerCustomModal(true)}
          style={{ marginVertical: 4 }}
        >
          Selection View (custom wrapper)
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
      <ActivityPickerPersisted
        visible={pickerNative}
        onDismiss={() => setPickerNative(false)}
        showNavigationBar
        onSelectionChange={(
          event: NativeSyntheticEvent<ActivitySelectionMetadata>,
        ) => {
          console.log("sheet view selection changed", event.nativeEvent);
        }}
        familyActivitySelectionId="picker-native"
        onReload={() => {
          setPickerNative(false);
          setTimeout(() => setPickerNative(true), 100);
        }}
      />
      <ActivityPickerPersisted
        visible={pickerCustomModal}
        onDismiss={() => setPickerCustomModal(false)}
        showNavigationBar={false}
        onSelectionChange={(
          event: NativeSyntheticEvent<ActivitySelectionMetadata>,
        ) => {
          console.log("selection view changed", event.nativeEvent);
        }}
        familyActivitySelectionId="picker-custom-modal"
        onReload={() => {
          setPickerCustomModal(false);
          setTimeout(() => setPickerCustomModal(true), 100);
        }}
      />
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
