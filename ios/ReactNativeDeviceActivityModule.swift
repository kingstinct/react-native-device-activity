import ExpoModulesCore
import DeviceActivity
import FamilyControls
import ManagedSettings
import os

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Robert testar")


struct DateComponentsFromJS: Record {
  @Field
  var era: Int?;
  @Field
  var year: Int?;
  @Field
  var month: Int?;
  @Field
  var day: Int?;
  @Field
  var hour: Int?;
  @Field
  var minute: Int?;
  @Field
  var second: Int?;
  @Field
  var nanosecond: Int?;
  @Field
  var weekday: Int?;
  @Field
  var weekdayOrdinal: Int?;
  @Field
  var quarter: Int?;
  @Field
  var weekOfMonth: Int?;
  @Field
  var weekOfYear: Int?;
  @Field
  var yearForWeekOfYear: Int?;
}

struct ScheduleFromJS: Record {
  @Field
  var intervalStart: DateComponentsFromJS
  @Field
  var intervalEnd: DateComponentsFromJS
  
  @Field
  var repeats: Bool?
  
  @Field
  var warningTime: DateComponentsFromJS?
}

struct DeviceActivityEventFromJS: Record {
  @Field
  var familyActivitySelection: String;
  @Field
  var threshold: DateComponentsFromJS;
  @Field
  var eventName: String;
}

func convertToSwiftDateComponents(from dateComponentsFromJS: DateComponentsFromJS) -> DateComponents {
  var swiftDateComponents = DateComponents()
  
  if let era = dateComponentsFromJS.era {
    swiftDateComponents.era = era
  }
  if let year = dateComponentsFromJS.year {
    swiftDateComponents.year = year
  }
  if let month = dateComponentsFromJS.month {
    swiftDateComponents.month = month
  }
  if let day = dateComponentsFromJS.day {
    swiftDateComponents.day = day
  }
  if let hour = dateComponentsFromJS.hour {
    swiftDateComponents.hour = hour
  }
  if let minute = dateComponentsFromJS.minute {
    swiftDateComponents.minute = minute
  }
  if let second = dateComponentsFromJS.second {
    swiftDateComponents.second = second
  }
  if let nanosecond = dateComponentsFromJS.nanosecond {
    swiftDateComponents.nanosecond = nanosecond
  }
  if let weekday = dateComponentsFromJS.weekday {
    swiftDateComponents.weekday = weekday
  }
  if let weekdayOrdinal = dateComponentsFromJS.weekdayOrdinal {
    swiftDateComponents.weekdayOrdinal = weekdayOrdinal
  }
  if let quarter = dateComponentsFromJS.quarter {
    swiftDateComponents.quarter = quarter
  }
  if let weekOfMonth = dateComponentsFromJS.weekOfMonth {
    swiftDateComponents.weekOfMonth = weekOfMonth
  }
  if let weekOfYear = dateComponentsFromJS.weekOfYear {
    swiftDateComponents.weekOfYear = weekOfYear
  }
  if let yearForWeekOfYear = dateComponentsFromJS.yearForWeekOfYear {
    swiftDateComponents.yearForWeekOfYear = yearForWeekOfYear
  }
  
  return swiftDateComponents
}

@available(iOS 15.0, *)
func base64StringToFamilyActivitySelection(base64String: String) -> FamilyActivitySelection? {
  // Step 1: Decode the base64 string to a Data object
  guard let data = Data(base64Encoded: base64String) else {
    print("Error: Invalid base64 string")
    return nil
  }
  
  // Step 2: Use NSKeyedUnarchiver to unarchive the data and create an HKQueryAnchor object
  do {
    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
    unarchiver.requiresSecureCoding = true
    let anchor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
    
    return anchor as? FamilyActivitySelection
  } catch {
    print("Error: Unable to unarchive HKQueryAnchor object: \(error)")
    return nil
  }
}

@available(iOS 15.0, *)
public class ReactNativeDeviceActivityModule: Module {
  
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
    //Constants([
    // "PI": Double.pi
    //])
    
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
    
    AsyncFunction("startMonitoring") { (activityName: String, schedule: ScheduleFromJS, events: [DeviceActivityEventFromJS]) in
      
      let schedule = DeviceActivitySchedule(
        intervalStart: convertToSwiftDateComponents(from: schedule.intervalStart),
        intervalEnd: convertToSwiftDateComponents(from: schedule.intervalEnd),
        repeats: true,
        warningTime: schedule.warningTime != nil
        ? convertToSwiftDateComponents(from: schedule.warningTime!)
        : nil
      )
      
      let dictionary = Dictionary(uniqueKeysWithValues: events.map { (event: DeviceActivityEventFromJS) in
        
        let decoder = JSONDecoder()
        let data = Data(base64Encoded: event.familyActivitySelection)!
        var applicationTokens: Set<ApplicationToken> = []
        var categories: Set<ActivityCategoryToken> = []
        var webDomainTokens: Set<WebDomainToken> = []
        do {
          let activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data)
          applicationTokens = activitySelection.applicationTokens
          categories = activitySelection.categoryTokens
          webDomainTokens = activitySelection.webDomainTokens
        }
        catch{
          
        }
        
        return (
          DeviceActivityEvent.Name(event.eventName),
          DeviceActivityEvent(
            applications: applicationTokens,
            categories: categor^\ies,
            webDomains: webDomainTokens,
            threshold: convertToSwiftDateComponents(from: event.threshold)
          )
        )
      })
      
      do {
        let activityName = DeviceActivityName(activityName)
        try center.startMonitoring(
          activityName,
          during: schedule,
          events: dictionary
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
    
    Events(
      "onSelectionChange"
    )
    
    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    View(ReactNativeDeviceActivityView.self) {
      Events(
        "onSelectionChange"
      )
      // Defines a setter for the `name` prop.
      Prop("familyActivitySelection") { (view: ReactNativeDeviceActivityView, prop: String) in
        do {
          let decoder = JSONDecoder()
          let data = Data(base64Encoded: prop)!
          let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
          
          view.model.activitySelection = selection
        } catch{
          
        }
        
      }
    }
  }
}
