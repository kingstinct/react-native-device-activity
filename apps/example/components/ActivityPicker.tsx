import React from "react";
import { NativeSyntheticEvent, Pressable, StyleSheet, Text, View } from "react-native";
import {
  ActivitySelectionMetadata,
  DeviceActivitySelectionSheetView,
  DeviceActivitySelectionSheetViewPersisted,
  ActivitySelectionWithMetadata,
  DeviceActivitySelectionView,
  DeviceActivitySelectionViewPersisted,
} from "react-native-device-activity";
import { Modal, Portal } from "react-native-paper";

const CrashView = ({ onReload }: { onReload: () => void }) => {
  return (
    <Pressable
      style={styles.crashView}
      onPress={onReload}
    >
      <Text>Swift view crash - tap to reload</Text>
    </Pressable>
  );
};

export const ActivityPicker = ({
  visible,
  onDismiss,
  onSelectionChange,
  familyActivitySelection,
  onReload,
  showNavigationBar = true,
}: {
  visible: boolean;
  onDismiss: () => void;
  onSelectionChange: (
    event: NativeSyntheticEvent<ActivitySelectionWithMetadata>,
  ) => void;
  familyActivitySelection: string | undefined;
  onReload: () => void;
  showNavigationBar?: boolean;
}) => {
  if (showNavigationBar) {
    // Native presentation: the native side uses the
    // .familyActivityPicker(isPresented:) modifier which presents its own
    // sheet.  We just mount a tiny anchor view — no RN Modal needed.
    if (!visible) return null;
    return (
      <DeviceActivitySelectionSheetView
        style={styles.nativeAnchor}
        onDismissRequest={onDismiss}
        onSelectionChange={onSelectionChange}
        familyActivitySelection={familyActivitySelection}
      />
    );
  }

  // Custom modal: react-native-paper Portal + Modal with fixed height.
  return (
    <Portal>
      <Modal
        visible={visible}
        onDismiss={onDismiss}
        contentContainerStyle={styles.modalContainer}
      >
        <View style={styles.modalContent}>
          <CrashView onReload={onReload} />
          {visible && (
            <DeviceActivitySelectionView
              style={styles.picker}
              onSelectionChange={onSelectionChange}
              familyActivitySelection={familyActivitySelection}
            />
          )}
        </View>
      </Modal>
    </Portal>
  );
};

export const ActivityPickerPersisted = ({
  visible,
  onDismiss,
  onSelectionChange,
  familyActivitySelectionId,
  onReload,
  includeEntireCategory,
  showNavigationBar = true,
}: {
  visible: boolean;
  onDismiss: () => void;

  onSelectionChange: (
    event: NativeSyntheticEvent<ActivitySelectionMetadata>,
  ) => void;
  familyActivitySelectionId: string;
  onReload: () => void;
  includeEntireCategory?: boolean;
  showNavigationBar?: boolean;
}) => {
  if (showNavigationBar) {
    if (!visible) return null;
    return (
      <DeviceActivitySelectionSheetViewPersisted
        style={styles.nativeAnchor}
        onDismissRequest={onDismiss}
        onSelectionChange={onSelectionChange}
        familyActivitySelectionId={familyActivitySelectionId}
        includeEntireCategory={includeEntireCategory}
      />
    );
  }

  return (
    <Portal>
      <Modal
        visible={visible}
        onDismiss={onDismiss}
        contentContainerStyle={styles.modalContainer}
      >
        <View style={styles.modalContent}>
          <CrashView onReload={onReload} />
          {visible && (
            <DeviceActivitySelectionViewPersisted
              style={styles.picker}
              onSelectionChange={onSelectionChange}
              familyActivitySelectionId={familyActivitySelectionId}
              includeEntireCategory={includeEntireCategory}
            />
          )}
        </View>
      </Modal>
    </Portal>
  );
};

const styles = StyleSheet.create({
  // Invisible anchor for the native .familyActivityPicker() modifier.
  nativeAnchor: {
    width: 1,
    height: 1,
    position: "absolute",
  },
  modalContainer: {
    height: 600,
  },
  modalContent: {
    flex: 1,
    height: 600,
  },
  crashView: {
    flex: 1,
    position: "absolute",
    height: 600,
    width: "100%",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "white",
  },
  picker: {
    flex: 1,
    height: 600,
    width: "100%",
    backgroundColor: "transparent",
  },
});
