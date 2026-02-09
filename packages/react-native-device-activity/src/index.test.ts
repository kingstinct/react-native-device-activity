// todo: skipping for now

describe("test", () => {
  test("Should export sheet picker views", () => {
    jest.isolateModules(() => {
      const module = require("./");
      expect(module.DeviceActivitySelectionSheetView).toBeDefined();
      expect(module.DeviceActivitySelectionSheetViewPersisted).toBeDefined();
    });
  });

  test("Should call stopMonitoring", () => {
    const mockStopMonitoring = jest.fn();
    jest.mock("./ReactNativeDeviceActivityModule", () => ({
      stopMonitoring: mockStopMonitoring,
    }));
    const { stopMonitoring } = require("./");
    stopMonitoring();
    expect(mockStopMonitoring).toHaveBeenCalled();
  });

  test("Should call startMonitoring", () => {
    jest.resetAllMocks();
    const mockStartMonitoring = jest.fn();
    jest.mock("./ReactNativeDeviceActivityModule", () => ({
      startMonitoring: mockStartMonitoring,
    }));
    const { startMonitoring } = require("./");
    startMonitoring("test", {}, []);
    expect(mockStartMonitoring).toHaveBeenCalled();
  });
});
