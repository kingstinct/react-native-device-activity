import ExpoModulesCore
import DeviceActivity
import FamilyControls
import os

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Robert testar")

@available(iOS 15.0, *)
public class ReactNativeDeviceActivityModule: Module {
  
  let activity = DeviceActivityName("Lifeline.AppLoggedTimeDaily")
  
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
    
    Function("getEvents") { () -> [AnyHashable: Any] in
      let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")
      let dict = userDefaults?.dictionaryRepresentation()

      guard let actualDict = dict else {
        return [:] // Return an empty dictionary instead of an empty array
      }

      let filteredDict = actualDict.filter({ (key: String, value: Any) in
        return key.starts(with: "activity_event_last_called_")
      }).reduce(into: [:]) { (result, element) in
        let (key, value) = element
        result[key] = value as? NSNumber // Add key-value pair to the result dictionary
      }

      return filteredDict
    }
    
    AsyncFunction("startMonitoring") {
      let timeLimitMinutes = 5
      
      let schedule = DeviceActivitySchedule(
          intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
          intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
          repeats: true,
          warningTime: DateComponents(minute: timeLimitMinutes - 1, second: 30)
      )
      
      
      let activitySelection = DeviceActivityModel.current.model.activitySelection
      let totalEvents = 24 * 60 / timeLimitMinutes // 24 hours * 60 minutes / timeLimitMinutes

      var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
      
      // let includeEntireCategory = activitySelection.includeEntireCategory

      for i in 0..<totalEvents {
        let name = "\((i + 1) * timeLimitMinutes)_minutes_today"
        logger.log("Creating event with name \(name)")
          let eventName = DeviceActivityEvent.Name(name)
          
          let event = DeviceActivityEvent(
              applications: activitySelection.applicationTokens,
              categories: activitySelection.categoryTokens,
              webDomains: activitySelection.webDomainTokens,
              threshold: DateComponents(minute: (i + 1) * timeLimitMinutes)
          )
          
          events[eventName] = event
      }


     
      do {
        
        try center.startMonitoring(
            activity,
            during: schedule,
            events: events
        )
          logger.log("😭😭😭 Success with Starting Monitor Activity")
        } catch {
          logger.log("😭😭😭 Error with Starting Monitor Activity: \(error.localizedDescription)")
        }
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
