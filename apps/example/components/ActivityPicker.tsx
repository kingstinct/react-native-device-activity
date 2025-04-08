import { Pressable, Text, View, NativeSyntheticEvent } from "react-native";
import {
  ActivitySelectionMetadata,
  ActivitySelectionWithMetadata,
  DeviceActivitySelectionView,
  DeviceActivitySelectionViewPersisted,
} from "react-native-device-activity";
import { Modal, Portal } from "react-native-paper";

const CrashView = ({ onReload }: { onReload: () => void }) => {
  return (
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
  );
};

export const ActivityPicker = ({
  visible,
  onDismiss,
  onSelectionChange,
  familyActivitySelection,
  onReload,
}: {
  visible: boolean;
  onDismiss: () => void;
  onSelectionChange: (
    event: NativeSyntheticEvent<ActivitySelectionWithMetadata>,
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
          <CrashView onReload={onReload} />

          {visible && (
            <DeviceActivitySelectionView
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

export const ActivityPickerPersisted = ({
  visible,
  onDismiss,
  onSelectionChange,
  familyActivitySelectionId,
  onReload,
  includeEntireCategory,
}: {
  visible: boolean;
  onDismiss: () => void;

  onSelectionChange: (
    event: NativeSyntheticEvent<ActivitySelectionMetadata>,
  ) => void;
  familyActivitySelectionId: string;
  onReload: () => void;
  includeEntireCategory?: boolean;
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
          <CrashView onReload={onReload} />

          {visible && (
            <DeviceActivitySelectionViewPersisted
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
              familyActivitySelectionId={familyActivitySelectionId}
              includeEntireCategory={includeEntireCategory}
            />
          )}
        </View>
      </Modal>
    </Portal>
  );
};
