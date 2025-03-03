import React, { useCallback, useMemo, useState } from "react";
import {
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  TextInput,
  Pressable,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import { UIBlurEffectStyle } from "react-native-device-activity/src/ReactNativeDeviceActivity.types";
import { Button, Modal, Portal, Switch } from "react-native-paper";

const ActivityPicker = ({
  visible,
  onDismiss,
  onSelectionChange,
  familyActivitySelection,
  onReload,
}: {
  visible: boolean;
  onDismiss: () => void;
  onSelectionChange: (
    event: NativeSyntheticEvent<{
      familyActivitySelection: string;
      applicationCount: number;
      categoryCount: number;
      webDomainCount: number;
    }>,
  ) => void;
  familyActivitySelection: string | undefined;
  onReload: () => void;
}) => {
  return (
    <Portal>
      <Modal
        visible={visible}
        onDismiss={onDismiss}
        contentContainerStyle={{
          height: 600,
        }}
      >
        <View
          style={{
            flex: 1,
            height: 600,
          }}
        >
          <Pressable
            style={{
              flex: 1,
              position: "absolute",
              height: 600,
              width: "100%",
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: "white",
            }}
            onPress={onReload}
          >
            <Text>Swift view crash - tap to reload</Text>
          </Pressable>

          {visible && (
            <ReactNativeDeviceActivity.DeviceActivitySelectionView
              style={{
                flex: 1,
                height: 600,
                width: "100%",
                backgroundColor: "transparent",
                pointerEvents: "none",
              }}
              headerText="a header text!"
              footerText="a footer text!"
              onSelectionChange={onSelectionChange}
              familyActivitySelection={familyActivitySelection}
            />
          )}
        </View>
      </Modal>
    </Portal>
  );
};

export function ShieldTab() {
  const [shieldTitle, setShieldTitle] = React.useState<string>("");

  const [familyActivitySelectionResult, setFamilyActivitySelectionResult] =
    React.useState<{
      applicationCount: number;
      categoryCount: number;
      webDomainCount: number;
      familyActivitySelection: string;
    } | null>(null);

  const [
    secondFamilyActivitySelectionResult,
    setSecondFamilyActivitySelectionResult,
  ] = React.useState<{
    applicationCount: number;
    categoryCount: number;
    webDomainCount: number;
    familyActivitySelection: string;
  } | null>(null);

  const [isShieldActive, setIsShieldActive] = useState(false);
  const [isShieldActiveWithSelection, setIsShieldActiveWithSelection] =
    useState(false);

  const refreshIsShieldActive = useCallback(() => {
    setIsShieldActive(ReactNativeDeviceActivity.isShieldActive());
    if (familyActivitySelectionResult?.familyActivitySelection) {
      setIsShieldActiveWithSelection(
        ReactNativeDeviceActivity.isShieldActiveWithSelection(
          familyActivitySelectionResult.familyActivitySelection,
        ),
      );
    } else {
      setIsShieldActiveWithSelection(false);
    }
  }, [familyActivitySelectionResult?.familyActivitySelection]);

  const onSelectionChange = useCallback(
    (
      event: NativeSyntheticEvent<{
        familyActivitySelection: string;
        applicationCount: number;
        categoryCount: number;
        webDomainCount: number;
      }>,
    ) => {
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
    (
      event: NativeSyntheticEvent<{
        familyActivitySelection: string;
        applicationCount: number;
        categoryCount: number;
        webDomainCount: number;
      }>,
    ) => {
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
      ReactNativeDeviceActivity.updateShield(
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

  const intersection = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? ReactNativeDeviceActivity.intersection(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const union = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? ReactNativeDeviceActivity.union(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const difference = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? ReactNativeDeviceActivity.difference(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const symmetricDifference = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection &&
      secondFamilyActivitySelectionResult?.familyActivitySelection
      ? ReactNativeDeviceActivity.symmetricDifference(
          familyActivitySelectionResult?.familyActivitySelection,
          secondFamilyActivitySelectionResult?.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult, secondFamilyActivitySelectionResult]);

  const activitySelectionMetadata = useMemo(() => {
    return familyActivitySelectionResult?.familyActivitySelection
      ? ReactNativeDeviceActivity.activitySelectionMetadata(
          familyActivitySelectionResult.familyActivitySelection,
        )
      : undefined;
  }, [familyActivitySelectionResult]);

  console.log("activitySelectionMetadata", activitySelectionMetadata);

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
            value={isShieldActive}
            onValueChange={async () => {
              if (isShieldActive) {
                await ReactNativeDeviceActivity.unblockApps();
              } else {
                await ReactNativeDeviceActivity.blockApps();
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
            value={isShieldActiveWithSelection}
            disabled={!familyActivitySelectionResult}
            onValueChange={async () => {
              if (isShieldActiveWithSelection) {
                await ReactNativeDeviceActivity.unblockApps();
              } else {
                await ReactNativeDeviceActivity.blockApps(
                  familyActivitySelectionResult?.familyActivitySelection,
                );
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
            familyActivitySelectionResult?.familyActivitySelection
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
            secondFamilyActivitySelectionResult?.familyActivitySelection
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
