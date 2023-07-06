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
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Robert testar")


// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
      logger.log("😭😭😭 intervalDidStart")
        // Handle the start of the interval.
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
      logger.log("😭😭😭 intervalDidEnd")
      

        // Handle the end of the interval.
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
      logger.log("😭😭😭 eventDidReachThreshold: \(event.rawValue, privacy: .public)")
      
      let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")
      let now = (Date().timeIntervalSince1970 * 1000).rounded()
      userDefaults?.set(now, forKey: "activity_event_last_called_\(event.rawValue)")
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
      logger.log("😭😭😭 intervalWillStartWarning")
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
      logger.log("😭😭😭 intervalWillEndWarning")
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
      logger.log("😭😭😭 eventWillReachThresholdWarning: \(event.rawValue, privacy: .public)")
      
        // Handle the warning before the event reaches its threshold.
    }
  
}
