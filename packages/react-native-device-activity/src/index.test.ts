// todo: skipping for now

describe("test", () => {
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
