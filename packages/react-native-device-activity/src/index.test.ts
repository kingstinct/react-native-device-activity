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

    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        stopMonitoring: mockStopMonitoring,
      }));
      const { stopMonitoring } = require("./");
      stopMonitoring();
    });

    expect(mockStopMonitoring).toHaveBeenCalled();
  });

  test("Should call startMonitoring", () => {
    const mockStartMonitoring = jest.fn();

    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        startMonitoring: mockStartMonitoring,
      }));
      const { startMonitoring } = require("./");
      startMonitoring("test", {}, []);
    });

    expect(mockStartMonitoring).toHaveBeenCalled();
  });

  test("Should call setWebContentFilterPolicy", () => {
    const mockSetWebContentFilterPolicy = jest.fn();
    const policy = {
      type: "auto",
      domains: ["adult.example.com"],
      exceptDomains: ["safe.example.com"],
    };

    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        setWebContentFilterPolicy: mockSetWebContentFilterPolicy,
      }));
      const { setWebContentFilterPolicy } = require("./");
      setWebContentFilterPolicy(policy, "test");
    });

    expect(mockSetWebContentFilterPolicy).toHaveBeenCalledWith(policy, "test");
  });

  test("Should call clearWebContentFilterPolicy", () => {
    const mockClearWebContentFilterPolicy = jest.fn();

    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        clearWebContentFilterPolicy: mockClearWebContentFilterPolicy,
      }));
      const { clearWebContentFilterPolicy } = require("./");
      clearWebContentFilterPolicy("test");
    });

    expect(mockClearWebContentFilterPolicy).toHaveBeenCalledWith("test");
  });

  test("Should return native value for isWebContentFilterPolicyActive", () => {
    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({
        isWebContentFilterPolicyActive: () => true,
      }));
      const { isWebContentFilterPolicyActive } = require("./");
      expect(isWebContentFilterPolicyActive()).toBe(true);
    });
  });

  test("Should return false fallback for isWebContentFilterPolicyActive", () => {
    jest.isolateModules(() => {
      jest.doMock("./ReactNativeDeviceActivityModule", () => ({}));
      const { isWebContentFilterPolicyActive } = require("./");
      expect(isWebContentFilterPolicyActive()).toBe(false);
    });
  });
});
