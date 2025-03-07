/* eslint-disable no-undef */
// Learn more https://docs.expo.io/guides/customizing-metro
const { getDefaultConfig } = require("expo/metro-config");
const path = require("node:path");

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, "../..");
const pathToLibrary = path.resolve(
  workspaceRoot,
  "packages/react-native-device-activity",
);

const config = getDefaultConfig(projectRoot);

// Make sure Metro can resolve modules from both the project and workspace root
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, "node_modules"),
  path.resolve(workspaceRoot, "node_modules"),
];

// Tell Metro where to find the package source
config.resolver.extraNodeModules = {
  "react-native-device-activity": pathToLibrary,
};

// Watch both the project root and the package
config.watchFolders = [projectRoot, pathToLibrary];

// Make sure Metro includes the project root in its search
// config.projectRoot = projectRoot;

config.transformer.getTransformOptions = async () => ({
  transform: {
    experimentalImportSupport: false,
    inlineRequires: true,
  },
});

module.exports = config;
