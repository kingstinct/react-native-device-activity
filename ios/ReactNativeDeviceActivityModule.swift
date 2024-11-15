import ExpoModulesCore
import ManagedSettingsUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import os
import Foundation

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

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
  @Field
  var timeZoneOffsetInSeconds: Int?;
  @Field
  var timeZoneIdentifier: String?;
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
  var familyActivitySelectionIndex: Int;
  @Field
  var threshold: DateComponentsFromJS;
  @Field
  var eventName: String;
  @Field
  var includesPastActivity: Bool?;
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
  if let timeZoneIdentifier = dateComponentsFromJS.timeZoneIdentifier {
    swiftDateComponents.timeZone = TimeZone(identifier: timeZoneIdentifier)
    if(swiftDateComponents.timeZone == nil){
      swiftDateComponents.timeZone = TimeZone(abbreviation: timeZoneIdentifier)
    }
  }
  if let timeZoneOffsetInSeconds = dateComponentsFromJS.timeZoneOffsetInSeconds {
    swiftDateComponents.timeZone = TimeZone(secondsFromGMT: timeZoneOffsetInSeconds)
  }
  
  return swiftDateComponents
}

class NativeEventObserver {
  let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
  let observer: UnsafeRawPointer
  
  func registerListener(name: String){
    let notificationName = name as CFString
       CFNotificationCenterAddObserver(notificationCenter,
                                       observer,
                                       { (
                                           center: CFNotificationCenter?,
                                           observer: UnsafeMutableRawPointer?,
                                           name: CFNotificationName?,
                                           object: UnsafeRawPointer?,
                                           userInfo: CFDictionary?
                                           ) in
         if let observer = observer, let name = name {

           let mySelf = Unmanaged<BaseModule>.fromOpaque(observer).takeUnretainedValue()
                                             print("Notification name: \(name)")
           
           mySelf.sendEvent("onDeviceActivityMonitorEvent" as String, [
            "callbackName": name.rawValue
           ])
         }
       },
       notificationName,
       nil,
       CFNotificationSuspensionBehavior.deliverImmediately)
  }
  
  init(module: BaseModule){
    observer = UnsafeRawPointer(Unmanaged.passUnretained(module).toOpaque())
    registerListener(name: "intervalDidStart")
    registerListener(name: "intervalDidEnd")
    registerListener(name: "eventDidReachThreshold")
    registerListener(name: "intervalWillStartWarning")
    registerListener(name: "intervalWillEndWarning")
    registerListener(name: "eventWillReachThresholdWarning") 
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
    
    let observer = NativeEventObserver(module: self)
      
    var userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")
      
    Function("setAppGroup") { (appGroup: String) in
        userDefaults = UserDefaults(suiteName: appGroup)
    }
    
    Function("getEvents") { (activityName: String?) -> [AnyHashable: Any] in
      
      let dict = userDefaults?.dictionaryRepresentation()
      
      guard let actualDict = dict else {
        return [:] // Return an empty dictionary instead of an empty array
      }
      
      let filteredDict = actualDict.filter({ (key: String, value: Any) in
        return key.starts(with: activityName == nil ? "DeviceActivityMonitorExtension#" : "DeviceActivityMonitorExtension#\(activityName!)#")
      }).reduce(into: [:]) { (result, element) in
        let (key, value) = element
        result[key] = value as? NSNumber // Add key-value pair to the result dictionary
      }
      
      return filteredDict
    }
      
      Function("userDefaultsSet") { (params: [String: Any]) in
          guard let key = params["key"] as? String,
                let value = params["value"] else {
              return
          }
          userDefaults?.set(value, forKey: key)
      }
      
      Function("userDefaultsGet") { (forKey: String) -> Any? in
        return userDefaults?.object(forKey: forKey)
      }
      
      Function("userDefaultsRemove") { (forKey: String) -> Any? in
          return userDefaults?.removeObject(forKey: forKey)
      }
      
      Function("userDefaultsClear") { () in
          let dictionary = userDefaults?.dictionaryRepresentation()
          dictionary?.keys.forEach { key in
              userDefaults?.removeObject(forKey: key)
          }
      }
      
      Function("userDefaultsAll") { () -> Any? in
          if let userDefaults = userDefaults {
              return userDefaults.dictionaryRepresentation()
          }
          return nil
      }
      
      Function("doesSelectionHaveOverlap") { (familyActivitySelections: [String]) in
          let decodedFamilyActivitySelections: [FamilyActivitySelection] = familyActivitySelections.map { familyActivitySelection in
            let decoder = JSONDecoder()
            let data = Data(base64Encoded: familyActivitySelection)
            do {
              let activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
              return activitySelection
            }
            catch {
              return FamilyActivitySelection()
            }
          }
          
          let hasOverlap = decodedFamilyActivitySelections.contains { selection in
              return decodedFamilyActivitySelections.contains { compareWith in
                  // if it's the same instance - skip comparison
                  if(compareWith == selection){
                      return false
                  }
                  
                  if(compareWith.applicationTokens.contains(where: { token in
                      return selection.applicationTokens.contains(token)
                  } )){
                      return true
                  }
                  
                  if(compareWith.categoryTokens.contains(where: { token in
                      return selection.categoryTokens.contains(token)
                  } )){
                      return true
                  }
                  
                  if(compareWith.webDomainTokens.contains(where: { token in
                      return selection.webDomainTokens.contains(token)
                  } )){
                      return true
                  }
                  
                  return false
              }
          }
          
          return hasOverlap
      }
      
      Function("authorizationStatus") {
          let currentStatus = AuthorizationCenter.shared.authorizationStatus

          return currentStatus.rawValue
      }
    
    AsyncFunction("startMonitoring") { (activityName: String, schedule: ScheduleFromJS, events: [DeviceActivityEventFromJS], familyActivitySelections: [String]) in
      let schedule = DeviceActivitySchedule(
        intervalStart: convertToSwiftDateComponents(from: schedule.intervalStart),
        intervalEnd: convertToSwiftDateComponents(from: schedule.intervalEnd),
        repeats: schedule.repeats ?? false,
        warningTime: schedule.warningTime != nil
        ? convertToSwiftDateComponents(from: schedule.warningTime!)
        : nil
      )
      
      let decodedFamilyActivitySelections = familyActivitySelections.map { familyActivitySelection in
        let decoder = JSONDecoder()
        let data = Data(base64Encoded: familyActivitySelection)
        do {
          let activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
          return activitySelection
        }
        catch {
          return FamilyActivitySelection()
        }
      }
      
    let dictionary = Dictionary<DeviceActivityEvent.Name, DeviceActivityEvent>(uniqueKeysWithValues: events.map { (eventRaw: DeviceActivityEventFromJS) in
        let familyActivitySelection = decodedFamilyActivitySelections[eventRaw.familyActivitySelectionIndex]
          
        /*userDefaults?.set(familyActivitySelections[eventRaw.familyActivitySelectionIndex], forKey: eventRaw.eventName + "_familyActivitySelection")*/
            
        let threshold = convertToSwiftDateComponents(from: eventRaw.threshold)
          var event: DeviceActivityEvent
          
          if #available(iOS 17.4, *) {
              event = DeviceActivityEvent(
                applications: familyActivitySelection.applicationTokens,
                categories: familyActivitySelection.categoryTokens,
                webDomains: familyActivitySelection.webDomainTokens,
                threshold: threshold,
                includesPastActivity: eventRaw.includesPastActivity ?? false
              )
          } else {
              event = DeviceActivityEvent(
                applications: familyActivitySelection.applicationTokens,
                categories: familyActivitySelection.categoryTokens,
                webDomains: familyActivitySelection.webDomainTokens,
                threshold: threshold
              )
          }
        
        return (
          DeviceActivityEvent.Name(eventRaw.eventName),
          event
        )
      })
      
      do {
        let activityName = DeviceActivityName(activityName)
          
        try center.startMonitoring(
          activityName,
          during: schedule,
          events: dictionary
        )
        logger.log("✅ Succeeded with Starting Monitor Activity: \(activityName.rawValue)")
      } catch {
        logger.log("❌ Failed with Starting Monitor Activity: \(error.localizedDescription)")
      }
    }
    
    Function("stopMonitoring") { (activityNames: [String]?) in
      if(activityNames == nil || activityNames?.count == 0){
        center.stopMonitoring()
        return
      }
      center.stopMonitoring(activityNames!.map({ activityName in
        return DeviceActivityName(activityName)
      }))
    }
      
      let store = ManagedSettingsStore()
      
      Function("updateShieldConfiguration") { (shieldConfiguration: [String:Any]) -> Void in
          logger.log("\(shieldConfiguration)")
        userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration")
      }
      
      Function("activities") {
        let activities = center.activities
          
        return activities.map { activity in
          return activity.rawValue
        }
      }
    
    AsyncFunction("requestAuthorization"){
      let ac = AuthorizationCenter.shared
      
      if #available(iOS 16.0, *) {
        try await ac.requestAuthorization(for: .individual)
      } else {
        logger.log("⚠️ iOS 16.0 or later is required to request authorization.")
      }
      
    }
      
      Function("blockAllApps"){
          store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
          store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
      }
      
      Function("unblockApps"){
          store.shield.applicationCategories = nil
          store.shield.webDomainCategories = nil
      }
      
      AsyncFunction("revokeAuthorization") { () async throws -> Void in
        let ac = AuthorizationCenter.shared
        
        return try await withCheckedThrowingContinuation { continuation in
          ac.revokeAuthorization { result in
            switch result {
            case .success:
              continuation.resume()
            case .failure(let error):
              logger.log("❌ Failed to revoke authorization: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          }
        }
      }
    
    Events(
      "onSelectionChange",
      "onDeviceActivityMonitorEvent"
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
        } catch {
          logger.log("❌ Failed to deserialize familyActivitySelection to FamilyActivitySelection: \(error.localizedDescription)")
        }
      }
        
        Prop("footerText") { (view: ReactNativeDeviceActivityView, prop: String?) in
          
            view.model.footerText = prop
          
        }
        
        Prop("headerText") { (view: ReactNativeDeviceActivityView, prop: String?) in
          
            view.model.headerText = prop
          
        }
    }
  }
}
