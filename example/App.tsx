import { useEffect } from "react";
import { StyleSheet, Text, View } from "react-native";
import * as ReactNativeDeviceActivity from "react-native-device-activity";

export default function App() {
  useEffect(() => {
    ReactNativeDeviceActivity.requestAuthorization();
    const listener = ReactNativeDeviceActivity.addSelectionChangeListener(
      (event) => {
        console.log(event);
      }
    );
    return () => {
      listener.remove();
    };
  }, []);
  return (
    <View style={styles.container}>
      <ReactNativeDeviceActivity.ReactNativeDeviceActivityView
        name="hello"
        style={{ width: 200, height: 200, backgroundColor: "red" }}
      >
        <View
          style={{ backgroundColor: "yellow", height: 100 }}
          pointerEvents="none"
        />
      </ReactNativeDeviceActivity.ReactNativeDeviceActivityView>

      <Text>{ReactNativeDeviceActivity.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
