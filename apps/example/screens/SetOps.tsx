import React, { useCallback, useMemo, useState } from "react";
import {
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
} from "react-native";
import {
  ActivitySelectionWithMetadata,
  intersection,
  union,
  difference,
  symmetricDifference,
  activitySelectionMetadata,
} from "react-native-device-activity";
import { Button } from "react-native-paper";

import { ActivityPicker } from "../components/ActivityPicker";

export function SetOpsTab() {
  const [familyActivitySelectionResult, setFamilyActivitySelectionResult] =
    React.useState<ActivitySelectionWithMetadata | null>(null);

  const [
    secondFamilyActivitySelectionResult,
    setSecondFamilyActivitySelectionResult,
  ] = React.useState<ActivitySelectionWithMetadata | null>(null);

  const onSelectionChange = useCallback(
    (event: NativeSyntheticEvent<ActivitySelectionWithMetadata>) => {
      if (
        event.nativeEvent.familyActivitySelection !==
        familyActivitySelectionResult?.familyActivitySelection
      ) {
        setFamilyActivitySelectionResult(event.nativeEvent);
      }
    },
    [familyActivitySelectionResult?.familyActivitySelection],
  );

  const onSecondSelectionChange = useCallback(
    (event: NativeSyntheticEvent<ActivitySelectionWithMetadata>) => {
      if (
        event.nativeEvent.familyActivitySelection !==
        familyActivitySelectionResult?.familyActivitySelection
      ) {
        setSecondFamilyActivitySelectionResult(event.nativeEvent);
      }
    },
    [secondFamilyActivitySelectionResult?.familyActivitySelection],
  );

  const [showSelectionView, setShowSelectionView] = useState<
    "first" | "second" | false
  >(false);

  const onDismiss = useCallback(() => {
    setShowSelectionView(false);
  }, []);

  const intersectionData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? intersection(
          {
            activitySelectionToken:
              familyActivitySelectionResult?.familyActivitySelection,
          },
          {
            activitySelectionToken:
              secondFamilyActivitySelectionResult?.familyActivitySelection,
          },
          {
            stripToken: true,
          },
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const unionData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? union(
          {
            activitySelectionToken:
              familyActivitySelectionResult?.familyActivitySelection,
          },
          {
            activitySelectionToken:
              secondFamilyActivitySelectionResult?.familyActivitySelection,
          },
          {
            stripToken: true,
          },
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const differenceData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? difference(
          {
            activitySelectionToken:
              familyActivitySelectionResult?.familyActivitySelection,
          },
          {
            activitySelectionToken:
              secondFamilyActivitySelectionResult?.familyActivitySelection,
          },
          {
            stripToken: true,
          },
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const symmetricDifferenceData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? symmetricDifference(
          {
            activitySelectionToken:
              familyActivitySelectionResult?.familyActivitySelection,
          },
          {
            activitySelectionToken:
              secondFamilyActivitySelectionResult?.familyActivitySelection,
          },
          {
            stripToken: true,
          },
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const activitySelectionMetadataData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection
      ? activitySelectionMetadata({
          activitySelectionToken:
            familyActivitySelectionResult.familyActivitySelection,
        })
      : undefined;
  }, [familyActivitySelectionResult]);

  const activitySelectionMetadataData2 = useMemo(() => {
    return secondFamilyActivitySelectionResult?.familyActivitySelection
      ? activitySelectionMetadata({
          activitySelectionToken:
            secondFamilyActivitySelectionResult.familyActivitySelection,
        })
      : undefined;
  }, [secondFamilyActivitySelectionResult]);

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
        />
        <View
          style={{
            flexDirection: "row",
            gap: 10,
            margin: 10,
            justifyContent: "space-between",
          }}
        >
          <Button onPress={() => setShowSelectionView("first")}>
            Select set 1
          </Button>
          <Button onPress={() => setShowSelectionView("second")}>
            Select set 2
          </Button>
        </View>
        <View
          style={{
            flexDirection: "row",
            gap: 10,
            margin: 10,
            justifyContent: "space-between",
          }}
        >
          {activitySelectionMetadataData ? (
            <Text>
              {JSON.stringify(activitySelectionMetadataData, null, 2)}
            </Text>
          ) : (
            <Text>None selected</Text>
          )}
          {activitySelectionMetadataData2 ? (
            <Text>
              {JSON.stringify(activitySelectionMetadataData2, null, 2)}
            </Text>
          ) : (
            <Text>None selected</Text>
          )}
        </View>
        <ActivityPicker
          onSelectionChange={onSelectionChange}
          familyActivitySelection={
            familyActivitySelectionResult?.familyActivitySelection ?? undefined
          }
          visible={showSelectionView === "first"}
          onDismiss={onDismiss}
          onReload={() => {
            onDismiss();
            setTimeout(() => {
              setShowSelectionView("first");
            }, 100);
          }}
        />
        <ActivityPicker
          onSelectionChange={onSecondSelectionChange}
          familyActivitySelection={
            secondFamilyActivitySelectionResult?.familyActivitySelection ??
            undefined
          }
          visible={showSelectionView === "second"}
          onDismiss={onDismiss}
          onReload={() => {
            onDismiss();
            setTimeout(() => {
              setShowSelectionView("second");
            }, 100);
          }}
        />
        <Text>
          {"intersection: " + JSON.stringify(intersectionData, null, 2)}
        </Text>
        <Text>{"union: " + JSON.stringify(unionData, null, 2)}</Text>
        <Text>{"difference: " + JSON.stringify(differenceData, null, 2)}</Text>
        <Text>
          {"symmetricDifference: " +
            JSON.stringify(symmetricDifferenceData, null, 2)}
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
