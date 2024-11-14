//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Robert Herber on 2023-07-05.
//

import DeviceActivity
import ManagedSettings
import Foundation
import os
import FamilyControls

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
  let store = ManagedSettingsStore()
  
  func sendNotification(name: String){
    let notificationName = CFNotificationName(name as CFString)

    CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, false)
  }

  func persistToUserDefaults(activityName: String, callbackName: String, eventName: String? = nil){
    let now = (Date().timeIntervalSince1970 * 1000).rounded()
    let fullEventName = eventName == nil
      ? "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)"
      : "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)#\(eventName!)"
    userDefaults?.set(now, forKey: fullEventName)
  }
  
  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    logger.log("intervalDidStart")

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidStart"
    )
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalDidStart")
    
    self.sendNotification(name: "intervalDidStart")
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    logger.log("intervalDidEnd")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidEnd"
    )
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalDidEnd")

    self.sendNotification(name: "intervalDidEnd")
  }
  
  func executeActionsForEvent(activityName: String, callbackName: String, eventName: String? = nil){
    let key = eventName != nil ? "actions_for_\(activityName)_\(callbackName)_\(eventName!)" : "actions_for_\(activityName)_\(callbackName)"
    if let actions = userDefaults?.array(forKey: key) {
      actions.forEach { actionRaw in
        if let action = actionRaw as? Dictionary<String, Any>{
          let type = action["type"] as? String
          
          if(type == "block"){
            logger.log("tring to get base64")
            if let familyActivitySelectionStr = action["familyActivitySelection"] as? String {
              var activitySelection = FamilyActivitySelection()
              
              logger.log("got base64")
              let decoder = JSONDecoder()
              let data = Data(base64Encoded: familyActivitySelectionStr)
              do {
                logger.log("decoding base64..")
                activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
                logger.log("decoded base64!")
              }
              catch {
                logger.log("decode error \(error.localizedDescription)")
              }
              
              store.shield.applications = activitySelection.applicationTokens
              store.shield.webDomains = activitySelection.webDomainTokens
              store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
              store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
              
              if let shieldConfiguration = action["shieldConfiguration"] as? Dictionary<String, Any> {
                // update default shield
                userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration")
                
                activitySelection.applicationTokens.forEach { applicationToken in
                  userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration_for_application_" + applicationToken.hashValue.formatted())
                }
                
                activitySelection.categoryTokens.forEach { categoryToken in
                  userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration_for_category_" + categoryToken.hashValue.formatted())
                }
                
                activitySelection.webDomainTokens.forEach { webDomainToken in
                  userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration_for_domain_" + webDomainToken.hashValue.formatted())
                }
              }
            }
          }
          else if(type == "unblock"){
            store.shield.applications = nil
            store.shield.webDomains = nil
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
            store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.none
          }
        }
      }
    }
  }
  
  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    logger.log("eventDidReachThreshold: \(event.rawValue, privacy: .public)")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventDidReachThreshold",
      eventName: event.rawValue
    )

    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "eventDidReachThreshold", eventName: event.rawValue)

    self.sendNotification(name: "eventDidReachThreshold")
  }
  
  override func intervalWillStartWarning(for activity: DeviceActivityName) {
    super.intervalWillStartWarning(for: activity)
    logger.log("intervalWillStartWarning")
      
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillStartWarning"
    )
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalWillStartWarning")

    self.sendNotification(name: "intervalWillStartWarning")
  }
  
  override func intervalWillEndWarning(for activity: DeviceActivityName) {
    super.intervalWillEndWarning(for: activity)
    logger.log("intervalWillEndWarning")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillEndWarning"
    )
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalWillEndWarning")

    self.sendNotification(name: "intervalWillEndWarning")
  }
  
  override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventWillReachThresholdWarning(event, activity: activity)
    logger.log("eventWillReachThresholdWarning: \(event.rawValue, privacy: .public)")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventWillReachThresholdWarning",
      eventName: event.rawValue
    )
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "eventWillReachThresholdWarning", eventName: event.rawValue)

    self.sendNotification(name: "eventWillReachThresholdWarning")
  }
  
}
