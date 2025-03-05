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
        pluginName === "react-native-device-activity" ||
        (process.env.INTERNALLY_TEST_EXAMPLE_PROJECT &&
          pluginName ===
            "../../packages/react-native-device-activity/app.plugin.js")
      );
    }

    return null;
  });

  const { appGroup } = plugin?.[1] ?? {};

  if (!appGroup) {
    console.error(
      "[react-native-device-activity] Required 'appGroup' property missing from Config Plugin",
    );
  }

  return appGroup;
};

module.exports = getAppGroupFromExpoConfig;
