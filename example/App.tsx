import { StyleSheet, Text, View } from 'react-native';

import * as ReactNativeDeviceActivity from 'react-native-device-activity';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{ReactNativeDeviceActivity.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
