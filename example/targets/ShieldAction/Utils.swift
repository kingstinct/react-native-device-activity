//
//  Utils.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-07.
//

import Foundation
import ManagedSettings
import UIKit
import os
import FamilyControls

let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")



@available(iOS 15.0, *)
struct SelectionWithActivityName {
  var selection: FamilyActivitySelection
  var activityName: String
}

@available(iOS 15.0, *)
func getFamilyActivitySelectionToActivityNameMap() -> [SelectionWithActivityName?]{
  if let familyActivitySelectionToActivityNameMap = userDefaults?.dictionary(forKey: "familyActivitySelectionToActivityNameMap") {
    return familyActivitySelectionToActivityNameMap.map { (key: String, value: Any) in
      if let familyActivitySelectionStr = value as? String {
        let activitySelection = getActivitySelectionFromStr(familyActivitySelectionStr: familyActivitySelectionStr)
        
        return SelectionWithActivityName(selection: activitySelection, activityName: key)
      }
      return nil
    }
  }
  return []
}

@available(iOS 15.0, *)
func getPossibleActivityName(
    applicationToken: ApplicationToken?,
    webDomainToken: WebDomainToken?,
    categoryToken: ActivityCategoryToken?
) -> String? {
    let familyActivitySelectionToActivityNameMap = getFamilyActivitySelectionToActivityNameMap()
    
    let foundIt = familyActivitySelectionToActivityNameMap.first(where: { (mapping) in
        if let mapping = mapping {
            if let applicationToken = applicationToken {
                if(mapping.selection.applicationTokens.contains(applicationToken)){
                    return true
                }
            }
            
            if let webDomainToken = webDomainToken {
                if(mapping.selection.webDomainTokens.contains(webDomainToken)){
                    return true
                }
            }
            
            if let categoryToken = categoryToken {
                if(mapping.selection.categoryTokens.contains(categoryToken)){
                    return true
                }
            }
        }
        
        return false
    })
    
    return foundIt??.activityName
}

@available(iOS 15.0, *)
func getActivitySelectionFromStr(familyActivitySelectionStr: String) -> FamilyActivitySelection {
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
  
  return activitySelection
}

@available(iOS 15.0, *)
func parseShieldActionResponse(_ action: Any?) -> ShieldActionResponse{

    if let actionResponseRaw = action as? Int {
        let actionResponse = ShieldActionResponse(rawValue: actionResponseRaw)
        return actionResponse ?? .none
    }

    return .none
}

func parseActions(_ actionsRaw: Any?) -> [Action]{
    if let actions = actionsRaw as? [[String: Any]] {
        return actions.map { action in
            if let actionType = action["type"] as? String {
                switch actionType {
                /*case "unblockSelf":
                    return Action.unblockSelf*/
                case "unblockAll":
                    return Action.unblockAll
                default:
                    return Action.unblockAll
                }
            }
            return Action.unblockAll
        }
    }
    return []
}

enum Action {
    case unblockAll
}

@available(iOS 15.0, *)
struct ShieldActionConfig {
    var response: ShieldActionResponse
    
    var actions: [Action]
}

@available(iOS 15.0, *)
func getShieldActionConfig(shieldAction: ShieldAction) -> ShieldActionConfig{
    let actionConfig = userDefaults?.dictionary(forKey: "shieldActionConfig")
    
    let shieldPrimaryActionResponse = parseShieldActionResponse(actionConfig?["primaryButtonActionResponse"])
    let shieldSecondaryActionResponse = parseShieldActionResponse(actionConfig?["secondaryButtonActionResponse"])
    let primaryActions = parseActions(actionConfig?["primaryButtonAction"])
    let secondaryActions = parseActions(actionConfig?["secondaryButtonAction"])
    
    return ShieldActionConfig(
        response: shieldAction == .primaryButtonPressed ? shieldPrimaryActionResponse : shieldSecondaryActionResponse,
        actions: shieldAction == .primaryButtonPressed ? primaryActions : secondaryActions
    )
}


func getColor(color: [String: Double]?) -> UIColor? {
  if let color = color {
    let red = color["red"] ?? 0
    let green = color["green"] ?? 0
    let blue = color["blue"] ?? 0
    let alpha = color["alpha"] ?? 1
    
    return UIColor(
      red: red / 255,
      green: green / 255,
      blue: blue / 255,
      alpha: alpha
    )
  }
  
  return nil
}


@available(iOS 15.0, *)
func saveShieldActionConfig(primary: ShieldActionConfig, secondary: ShieldActionConfig) {
    userDefaults?.set([
        "primaryButtonActionResponse": primary.response.rawValue,
        "primaryButtonAction": primary.actions.map({ action in
            return ["type": "unblockAll"]
        }),
        "secondaryButtonActionResponse": secondary.response.rawValue,
        "secondaryButtonAction": secondary.actions.map({ action in
            return ["type": "unblockAll"]
        })
    ], forKey: "shieldActionConfig")
}

func persistToUserDefaults(activityName: String, callbackName: String, eventName: String? = nil){
  let now = (Date().timeIntervalSince1970 * 1000).rounded()
  let fullEventName = eventName == nil
    ? "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)"
    : "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)#\(eventName!)"
  userDefaults?.set(now, forKey: fullEventName)
}

@available(iOS 15.0, *)
let store = ManagedSettingsStore()

@available(iOS 15.0, *)
func executeShieldActionConfig(shieldAction: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    let actionConfig = getShieldActionConfig(shieldAction: shieldAction)
    
    actionConfig.actions.forEach { action in
        switch action {
            /*case .unblockSelf:
                // todo
                store.shield.applications = nil
                store.shield.webDomains = nil
                store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
                store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.none*/
            case .unblockAll:
                store.shield.applications = nil
                store.shield.webDomains = nil
                store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
                store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.none
        }
    }
    
    completionHandler(actionConfig.response)
}
