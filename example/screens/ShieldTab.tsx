import React, { useCallback, useEffect, useState } from "react";
import {
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  TextInput,
  TouchableOpacity,
  Pressable,
} from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";
import { UIBlurEffectStyle } from "react-native-device-activity/ReactNativeDeviceActivity.types";
import { Button, Modal, Portal, Switch, useTheme } from "react-native-paper";

export function ShieldTab() {
  const [shieldTitle, setShieldTitle] = React.useState<string>("");

  const [familyActivitySelectionResult, setFamilyActivitySelectionResult] =
    React.useState<{
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

  const onSubmitEditing = useCallback(
    () =>
      ReactNativeDeviceActivity.updateShield(
        {
          title: shieldTitle,
          backgroundBlurStyle: UIBlurEffectStyle.systemMaterialDark,
          // backgroundColor: null,
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

  const [showSelectionView, setShowSelectionView] = useState(false);

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
        <Button onPress={() => setShowSelectionView(true)}>
          Show selection view
        </Button>
        <Portal>
          <Modal
            visible={showSelectionView}
            onDismiss={() => setShowSelectionView(false)}
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
                onPress={() => {
                  setShowSelectionView(false);
                  setTimeout(() => {
                    setShowSelectionView(true);
                  }, 100);
                }}
              >
                <Text>Swift view crash - tap to reload</Text>
              </Pressable>

              {showSelectionView && (
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
                  familyActivitySelection={
                    familyActivitySelectionResult?.familyActivitySelection
                  }
                />
              )}
            </View>
          </Modal>
        </Portal>
        <Text>
          {familyActivitySelectionResult &&
          familyActivitySelectionResult?.categoryCount < 13
            ? `${familyActivitySelectionResult?.applicationCount} apps, ${familyActivitySelectionResult?.categoryCount} categories, ${familyActivitySelectionResult?.webDomainCount} domains`
            : familyActivitySelectionResult?.categoryCount
              ? "All categories selected"
              : "Nothing selected"}
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
