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

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
  let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")
  
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

    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidStart"
    )
    
    self.sendNotification(name: "intervalDidStart")
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    logger.log("intervalDidEnd")
    
    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidEnd"
    )

    self.sendNotification(name: "intervalDidEnd")
  }
  
  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    logger.log("eventDidReachThreshold: \(event.rawValue, privacy: .public)")
    
    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventDidReachThreshold", 
      eventName: event.rawValue
    )

    self.sendNotification(name: "eventDidReachThreshold")
  }
  
  override func intervalWillStartWarning(for activity: DeviceActivityName) {
    super.intervalWillStartWarning(for: activity)
    logger.log("intervalWillStartWarning")
      
    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillStartWarning"
    )

    self.sendNotification(name: "intervalWillStartWarning")
  }
  
  override func intervalWillEndWarning(for activity: DeviceActivityName) {
    super.intervalWillEndWarning(for: activity)
    logger.log("intervalWillEndWarning")
    
    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillEndWarning"
    )

    self.sendNotification(name: "intervalWillEndWarning")
  }
  
  override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventWillReachThresholdWarning(event, activity: activity)
    logger.log("eventWillReachThresholdWarning: \(event.rawValue, privacy: .public)")
    
    self.persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventWillReachThresholdWarning",
      eventName: event.rawValue
    )

    self.sendNotification(name: "eventWillReachThresholdWarning")
  }
  
}
