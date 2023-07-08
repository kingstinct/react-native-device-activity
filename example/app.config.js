require("ts-node/register");

module.exports = ({ config }) => ({
  ...config,
  plugins: [
    [
      require("expo-apple-targets/target-plugin").withTargetsDir,
      {
        appleTeamId: "34SE8X7Q58",
        // match: "watch-app",
      },
    ],
  ],
});
