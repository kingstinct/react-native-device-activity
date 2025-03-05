import React, { useCallback, useMemo, useState } from "react";
import {
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  TextInput,
} from "react-native";
import {
  UIBlurEffectStyle,
  ActivitySelectionWithMetadata,
  isShieldActive,
  isShieldActiveWithSelection,
  updateShield,
  intersection,
  union,
  difference,
  symmetricDifference,
  activitySelectionMetadata,
  unblockAllApps,
  blockAllApps,
  blockAppsWithSelectionId,
  unblockSelectedApps,
} from "react-native-device-activity";
import { Button, Switch } from "react-native-paper";

import { ActivityPicker } from "../components/ActivityPicker";

export function ShieldTab() {
  const [shieldTitle, setShieldTitle] = React.useState<string>("");

  const [familyActivitySelectionResult, setFamilyActivitySelectionResult] =
    React.useState<ActivitySelectionWithMetadata | null>(null);

  const [
    secondFamilyActivitySelectionResult,
    setSecondFamilyActivitySelectionResult,
  ] = React.useState<ActivitySelectionWithMetadata | null>(null);

  const [isShieldUp, setIsShieldUp] = useState(false);
  const [isShieldUpWithSelection, setIsShieldUpWithSelection] = useState(false);

  const refreshIsShieldActive = useCallback(() => {
    setIsShieldUp(isShieldActive());
    if (familyActivitySelectionResult?.familyActivitySelection) {
      setIsShieldUpWithSelection(
        isShieldActiveWithSelection(
          familyActivitySelectionResult.familyActivitySelection,
        ),
      );
    } else {
      setIsShieldUpWithSelection(false);
    }
  }, [familyActivitySelectionResult?.familyActivitySelection]);

  const onSelectionChange = useCallback(
    (event: NativeSyntheticEvent<ActivitySelectionWithMetadata>) => {
      if (
        event.nativeEvent.familyActivitySelection !==
        familyActivitySelectionResult?.familyActivitySelection
      ) {
        setFamilyActivitySelectionResult(event.nativeEvent);
        refreshIsShieldActive();
      }
    },
    [
      familyActivitySelectionResult?.familyActivitySelection,
      refreshIsShieldActive,
    ],
  );

  const onSecondSelectionChange = useCallback(
    (event: NativeSyntheticEvent<ActivitySelectionWithMetadata>) => {
      if (
        event.nativeEvent.familyActivitySelection !==
        familyActivitySelectionResult?.familyActivitySelection
      ) {
        setSecondFamilyActivitySelectionResult(event.nativeEvent);
        refreshIsShieldActive();
      }
    },
    [
      secondFamilyActivitySelectionResult?.familyActivitySelection,
      refreshIsShieldActive,
    ],
  );

  const onSubmitEditing = useCallback(
    () =>
      updateShield(
        {
          title: shieldTitle,
          backgroundBlurStyle: UIBlurEffectStyle.systemMaterialDark,
          backgroundColor: {
            red: 255,
            green: 0,
            blue: 0,
          },
          titleColor: {
            red: 255,
            green: 0,
            blue: 0,
          },
          subtitle: "subtitle",
          primaryButtonLabel: "primaryButtonLabel",
          secondaryButtonLabel: "secondaryButtonLabel",
          subtitleColor: {
            red: Math.random() * 255,
            green: Math.random() * 255,
            blue: Math.random() * 255,
          },
          primaryButtonBackgroundColor: {
            red: Math.random() * 255,
            green: Math.random() * 255,
            blue: Math.random() * 255,
          },
          primaryButtonLabelColor: {
            red: Math.random() * 255,
            green: Math.random() * 255,
            blue: Math.random() * 255,
          },
          secondaryButtonLabelColor: {
            red: Math.random() * 255,
            green: Math.random() * 255,
            blue: Math.random() * 255,
          },
        },
        {
          primary: {
            type: "openApp",
            behavior: "close",
          },
          secondary: {
            type: "dismiss",
            behavior: "defer",
          },
        },
      ),
    [shieldTitle],
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
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const unionData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? union(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const differenceData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? difference(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const symmetricDifferenceData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? symmetricDifference(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const activitySelectionMetadataData = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection
      ? activitySelectionMetadata(
          familyActivitySelectionResult.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult]);

  console.log("activitySelectionMetadata", activitySelectionMetadataData);

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
                unblockAllApps();
              } else {
                blockAllApps();
              }
              refreshIsShieldActive();
            }}
          />
          <Text>Shield active</Text>
        </View>

        <View
          style={{
            flexDirection: "row",
            gap: 10,
            margin: 10,
            alignItems: "center",
          }}
        >
          <Switch
            value={isShieldUpWithSelection}
            disabled={!familyActivitySelectionResult}
            onValueChange={async () => {
              const familyActivitySelectionId =
                familyActivitySelectionResult?.familyActivitySelection;
              if (familyActivitySelectionId) {
                if (isShieldUpWithSelection) {
                  unblockSelectedApps(familyActivitySelectionId);
                } else {
                  blockAppsWithSelectionId(familyActivitySelectionId);
                }
              }
              refreshIsShieldActive();
            }}
          />
          <Text style={{ flex: 1 }}>Block selected apps</Text>
        </View>
        <Button onPress={() => setShowSelectionView("first")}>
          Show selection (1)
        </Button>
        <Button onPress={() => setShowSelectionView("second")}>
          Show selection (2)
        </Button>
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
          {familyActivitySelectionResult &&
          familyActivitySelectionResult?.categoryCount < 13
            ? `${familyActivitySelectionResult?.applicationCount} apps, ${familyActivitySelectionResult?.categoryCount} categories, ${familyActivitySelectionResult?.webDomainCount} domains`
            : familyActivitySelectionResult?.categoryCount
              ? "All categories selected"
              : "Nothing selected"}
        </Text>
        <Text>{"intersection: " + JSON.stringify(intersection, null, 2)}</Text>
        <Text>{"union: " + JSON.stringify(union, null, 2)}</Text>
        <Text>{"difference: " + JSON.stringify(difference, null, 2)}</Text>
        <Text>
          {"symmetricDifference: " +
            JSON.stringify(symmetricDifference, null, 2)}
        </Text>
        <Text>
          {"activitySelectionMetadata: " +
            JSON.stringify(activitySelectionMetadata, null, 2)}
        </Text>
        <TextInput
          placeholder="Enter shield title"
          onChangeText={(text) => setShieldTitle(text)}
          value={shieldTitle}
          onSubmitEditing={onSubmitEditing}
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
