jest.mock("fs", () => ({
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
  cpSync: jest.fn(),
  readdirSync: jest.fn(),
  lstatSync: jest.fn(),
}));

const fs = require("fs");

const createExpoTargetConfig = require("../../config-plugin/createExpoTargetConfig");
const getAppGroupFromExpoConfig = require("../../config-plugin/getAppGroupFromExpoConfig");

describe("config plugin helpers", () => {
  const originalEnv = { ...process.env };

  beforeEach(() => {
    jest.clearAllMocks();
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  describe("getAppGroupFromExpoConfig", () => {
    it("extracts appGroup from react-native-device-activity plugin config", () => {
      const config = {
        plugins: [
          ["react-native-device-activity", { appGroup: "group.primary" }],
        ],
      };

      expect(getAppGroupFromExpoConfig(config)).toBe("group.primary");
    });

    it("extracts appGroup from internal example path when env toggle is enabled", () => {
      process.env.INTERNALLY_TEST_EXAMPLE_PROJECT = "true";
      const config = {
        plugins: [
          [
            "../../packages/react-native-device-activity/app.plugin.js",
            { appGroup: "group.internal" },
          ],
        ],
      };

      expect(getAppGroupFromExpoConfig(config)).toBe("group.internal");
    });

    it("logs and returns undefined when appGroup is missing", () => {
      const errorSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});
      const config = {
        plugins: [["react-native-device-activity", {}]],
      };

      expect(getAppGroupFromExpoConfig(config)).toBeUndefined();
      expect(errorSpy).toHaveBeenCalled();
      errorSpy.mockRestore();
    });
  });

  describe("withCopyTargetFolder", () => {
    it("skips copying when copyToTargetFolder is false and env override is absent", () => {
      const withCopyTargetFolder = require("../../config-plugin/withCopyTargetFolder");
      const config = { _internal: { projectRoot: "/tmp/example" } };

      const result = withCopyTargetFolder(config, {
        copyToTargetFolder: false,
      });

      expect(result).toBe(config);
      expect(fs.cpSync).not.toHaveBeenCalled();
    });

    it("copies targets when COPY_TO_TARGET_FOLDER is set", () => {
      process.env.COPY_TO_TARGET_FOLDER = "true";
      fs.existsSync.mockReturnValue(true);
      fs.readdirSync.mockReturnValue(["ShieldAction"]);
      fs.lstatSync.mockReturnValue({ isDirectory: () => true });

      const withCopyTargetFolder = require("../../config-plugin/withCopyTargetFolder");
      const config = { _internal: { projectRoot: "/tmp/example" } };

      withCopyTargetFolder(config, { copyToTargetFolder: false });

      expect(fs.cpSync).toHaveBeenCalled();
    });
  });

  describe("createExpoTargetConfig", () => {
    it("returns target config with deterministic entitlements", () => {
      const fn = createExpoTargetConfig.createConfig("shield-action");
      const config = {
        plugins: [
          ["react-native-device-activity", { appGroup: "group.primary" }],
        ],
      };

      expect(fn(config)).toEqual({
        type: "shield-action",
        entitlements: {
          "com.apple.developer.family-controls": true,
          "com.apple.security.application-groups": ["group.primary"],
        },
      });
    });
  });
});
