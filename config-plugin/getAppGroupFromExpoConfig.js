/**
 * Extracts the app group from Expo config
 * @param {import("expo/config").ExpoConfig} config - The Expo config object
 * @returns {string|undefined} The app group identifier or undefined if not found
 */
const getAppGroupFromExpoConfig = (config) => {
  const plugin = config.plugins?.find((plugin) => {
    if (Array.isArray(plugin)) {
      const [pluginName] = plugin;
      return (
        pluginName === "react-native-device-activity"
        // || pluginName === "../app.plugin.js" // only for trying it out locally
      );
    }

    return null;
  });

  const pluginProps = plugin?.[1];

  const appGroup = pluginProps?.appGroup;

  if (!appGroup) {
    throw new Error(
      "[react-native-device-activity] Required 'appGroup' property missing from Config Plugin",
    );
  }

  return appGroup;
};

export default getAppGroupFromExpoConfig;
