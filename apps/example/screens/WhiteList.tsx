import React, { useCallback, useEffect, useMemo, useState } from "react";
import {
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
} from "react-native";
import {
  isShieldActive,
  activitySelectionMetadata,
  disableBlockAllMode,
  enableBlockAllMode,
  clearWhitelistAndUpdateBlock,
  addSelectionToWhitelistAndUpdateBlock,
  ActivitySelectionMetadata,
  resetBlocks,
  clearWhitelist,
} from "react-native-device-activity";
import { Button, Switch } from "react-native-paper";

import { ActivityPickerPersisted } from "../components/ActivityPicker";

const selectionId = "whitelistTabWhitelist2";

export function WhiteListTab() {
  const [isShieldUp, setIsShieldUp] = useState(false);
  const [metadata, setMetadata] = useState<ActivitySelectionMetadata | null>(
    null,
  );
  const [whitelistMetadata, setWhitelistMetadata] = useState<
    ActivitySelectionMetadata | undefined
  >(undefined);

  useEffect(() => {
    refreshIsShieldActive();
  }, []);

  const refreshIsShieldActive = useCallback(() => {
    setIsShieldUp(isShieldActive());
  }, []);

  const onSelectionChange = useCallback(
    (event: NativeSyntheticEvent<ActivitySelectionMetadata>) => {
      setMetadata(event.nativeEvent);

      if (
        event.nativeEvent.applicationCount > 0 ||
        event.nativeEvent.categoryCount > 0 ||
        event.nativeEvent.webDomainCount > 0
      ) {
        clearWhitelist();
        addSelectionToWhitelistAndUpdateBlock({
          activitySelectionId: selectionId,
        });
        const metadata = activitySelectionMetadata({
          currentWhitelist: true,
        });

        setWhitelistMetadata(metadata);
        refreshIsShieldActive();
      }
    },
    [refreshIsShieldActive],
  );

  const [showSelectionView, setShowSelectionView] = useState<
    "first" | "second" | false
  >(false);

  const onDismiss = useCallback(() => {
    setShowSelectionView(false);
  }, []);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView style={styles.container}>
        <View
          style={{
            flexDirection: "row",
            gap: 10,
            margin: 10,
            alignItems: "center",
          }}
        >
          <Switch
            value={isShieldUp}
            onValueChange={async () => {
              if (isShieldUp) {
                disableBlockAllMode();
                resetBlocks();
              } else {
                enableBlockAllMode();
              }
              refreshIsShieldActive();
            }}
          />
          <Text>Shield active</Text>
        </View>
        <Button onPress={() => setShowSelectionView("first")}>
          Select apps to whitelist
        </Button>
        <ActivityPickerPersisted
          onSelectionChange={onSelectionChange}
          familyActivitySelectionId={selectionId}
          includeEntireCategory
          visible={showSelectionView === "first"}
          onDismiss={onDismiss}
          onReload={() => {
            onDismiss();
            setTimeout(() => {
              setShowSelectionView("first");
            }, 100);
          }}
        />
        <Text>
          {"activitySelectionMetadata: " + JSON.stringify(metadata, null, 2)}
        </Text>
        <Text>
          {"whitelistSelectionMetadata: " +
            JSON.stringify(whitelistMetadata, null, 2)}
        </Text>
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
