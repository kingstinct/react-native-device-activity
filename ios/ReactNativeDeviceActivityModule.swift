import ExpoModulesCore
import DeviceActivity
import FamilyControls



@available(iOS 15.0, *)
public class ReactNativeDeviceActivityModule: Module {
  
  let activity = DeviceActivityName("MyApp.ScreenTime")
  
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ReactNativeDeviceActivity')` in JavaScript.
    Name("ReactNativeDeviceActivity")
    
    let center = DeviceActivityCenter()
    

    // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
    Constants([
      "PI": Double.pi
    ])

    // Defines event names that the module can send to JavaScript.
    Events("onSelectionChange")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("hello") {
      return "Hello world! 👋"
    }
    
    
    
    AsyncFunction("startMonitoring") {
      let schedule = DeviceActivitySchedule(
          intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
          intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
          repeats: true
      )
      
      let timeLimitMinutes = 30
      
      var model = DeviceActivityModel.current.model

      let event = DeviceActivityEvent(
        applications: model.activitySelection.applicationTokens,
          categories: model.activitySelection.categoryTokens,
          webDomains: model.activitySelection.webDomainTokens,
          threshold: DateComponents(minute: timeLimitMinutes)
      )
      
      
      let eventName = DeviceActivityEvent.Name("MyApp.SomeEventName")

      try center.startMonitoring(
          activity,
          during: schedule,
          events: [
              eventName: event
          ]
      )
    }
    
    Function("stopMonitoring") {
      center.stopMonitoring()
    }
  
    AsyncFunction("requestAuthorization"){
      let ac = AuthorizationCenter.shared

      if #available(iOS 16.0, *) {
        try await ac.requestAuthorization(for: .individual)
      } else {
        // Fallback on earlier versions
      }
      
    }

    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setValueAsync") { (value: String) in
      // Send an event to JavaScript.
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    View(ReactNativeDeviceActivityView.self) {
      
      Events(
        "onSelectionChanged"
      )
      // Defines a setter for the `name` prop.
      Prop("name") { (view: ReactNativeDeviceActivityView, prop: String) in
        print(prop)
      }
    }
  }
}
