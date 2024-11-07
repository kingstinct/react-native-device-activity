//
//  Utils.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-07.
//

import Foundation
import ManagedSettings

let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")

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

@available(iOS 15.0, *)
func saveShieldActionConfig(primary: ShieldActionConfig, secondary: ShieldActionConfig) {
    let actionConfig = userDefaults?.dictionary(forKey: "shieldActionConfig")
    
    userDefaults?.set([
        "primaryButtonActionResponse": primary.response.rawValue,
        "primaryButtonAction": primary.actions.map({ action in
            return ["type": "unblockAll"]
        }),
        "secondaryButtonActionResponse": secondary.response.rawValue,
        "secondaryButtonAction": primary.actions.map({ action in
            return ["type": "unblockAll"]
        })
    ], forKey: "shieldActionConfig")
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
