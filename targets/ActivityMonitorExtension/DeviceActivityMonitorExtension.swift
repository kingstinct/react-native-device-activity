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

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
  let store = ManagedSettingsStore()
  
  func notifyAppWithName(name: String){
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
    
    self.notifyAppWithName(name: "intervalDidStart")
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalDidStart")
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    logger.log("intervalDidEnd")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidEnd"
    )
    
    self.notifyAppWithName(name: "intervalDidEnd")
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalDidEnd")
  }
  
  func executeActionsForEvent(activityName: String, callbackName: String, eventName: String? = nil){
    let key = eventName != nil ? "actions_for_\(activityName)_\(callbackName)_\(eventName!)" : "actions_for_\(activityName)_\(callbackName)"
    let placeholders = ["activityName": activityName, "callbackName": callbackName, "eventName": eventName]
    if let actions = userDefaults?.array(forKey: key) {
      actions.forEach { actionRaw in
        if let action = actionRaw as? Dictionary<String, Any>{
          executeAction(action: action, placeholders: placeholders)
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
    
    self.notifyAppWithName(name: "eventDidReachThreshold")

    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "eventDidReachThreshold", eventName: event.rawValue)
  }
  
  override func intervalWillStartWarning(for activity: DeviceActivityName) {
    super.intervalWillStartWarning(for: activity)
    logger.log("intervalWillStartWarning")
      
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillStartWarning"
    )
    
    self.notifyAppWithName(name: "intervalWillStartWarning")
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalWillStartWarning")
  }
  
  override func intervalWillEndWarning(for activity: DeviceActivityName) {
    super.intervalWillEndWarning(for: activity)
    logger.log("intervalWillEndWarning")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillEndWarning"
    )
    
    self.notifyAppWithName(name: "intervalWillEndWarning")
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "intervalWillEndWarning")
  }
  
  override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventWillReachThresholdWarning(event, activity: activity)
    logger.log("eventWillReachThresholdWarning: \(event.rawValue, privacy: .public)")
    
    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventWillReachThresholdWarning",
      eventName: event.rawValue
    )
    
    self.notifyAppWithName(name: "eventWillReachThresholdWarning")
    
    self.executeActionsForEvent(activityName: activity.rawValue, callbackName: "eventWillReachThresholdWarning", eventName: event.rawValue)
  }
  
}
