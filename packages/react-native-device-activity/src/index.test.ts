jest.mock("expo-modules-core", () => {
  class MockEventEmitter {
    addListener() {
      return { remove: jest.fn() };
    }

    removeAllListeners() {}
  }

  return {
    EventEmitter: MockEventEmitter,
    EventSubscription: class {},
    requireNativeViewManager: jest.fn(() => () => null),
  };
});

describe("index runtime wrapper", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.resetModules();
  });

  test("delegates stopMonitoring to native module", () => {
    jest.isolateModules(() => {
      const mockNativeModule = {
        stopMonitoring: jest.fn(),
        startMonitoring: jest.fn(),
      };

      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        __esModule: true,
        default: mockNativeModule,
      }));

      const { stopMonitoring } = require("./index");
      const activities = ["activity-a"];

      stopMonitoring(activities);

      expect(mockNativeModule.stopMonitoring).toHaveBeenCalledWith(activities);
    });
  });

  test("delegates startMonitoring to native module", async () => {
    await jest.isolateModulesAsync(async () => {
      const mockNativeModule = {
        stopMonitoring: jest.fn(),
        startMonitoring: jest.fn().mockResolvedValue(undefined),
      };

      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        __esModule: true,
        default: mockNativeModule,
      }));

      const { startMonitoring } = require("./index");

      await startMonitoring(
        "activity-a",
        {
          intervalStart: { hour: 0, minute: 0 },
          intervalEnd: { hour: 23, minute: 59 },
        },
        [],
      );

      expect(mockNativeModule.startMonitoring).toHaveBeenCalled();
    });
  });
});
