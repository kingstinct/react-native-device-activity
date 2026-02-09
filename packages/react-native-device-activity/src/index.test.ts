const mockNativeModule = {
  stopMonitoring: jest.fn(),
  startMonitoring: jest.fn(),
};

jest.mock("react-native", () => ({
  Platform: {
    OS: "ios",
    select: (options: Record<string, unknown>) =>
      options.ios ?? options.default,
  },
}));

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
  };
});

jest.mock("./ReactNativeDeviceActivityModule", () => ({
  __esModule: true,
  default: mockNativeModule,
}));

describe("index runtime wrapper", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.resetModules();
  });

  test("delegates stopMonitoring to native module", () => {
    const { stopMonitoring } = require("./index");
    const activities = ["activity-a"];

    stopMonitoring(activities);

    expect(mockNativeModule.stopMonitoring).toHaveBeenCalledWith(activities);
  });

  test("delegates startMonitoring to native module", async () => {
    mockNativeModule.startMonitoring.mockResolvedValueOnce(undefined);
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
