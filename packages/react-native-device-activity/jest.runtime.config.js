module.exports = {
  testEnvironment: "node",
  clearMocks: true,
  roots: ["<rootDir>/src"],
  testRegex: ".*\\.test\\.ts$",
  transform: {
    "^.+\\.[jt]sx?$": [
      "babel-jest",
      {
        configFile: require.resolve("expo-module-scripts/babel.config.cli.js"),
      },
    ],
  },
};
