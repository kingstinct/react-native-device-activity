//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Robert Herber on 2024-10-25.
//

import ManagedSettings
import UIKit

func handleAction(configForSelectedAction: [String: Any]) -> ShieldActionResponse {
  logger.log("handleAction")
  if let type = configForSelectedAction["type"] as? String {
    if type == "unblockAll" {
      unblockAllApps()
    }
  }

  if let behavior = configForSelectedAction["behavior"] as? String {
    if behavior == "defer" {
      return .defer
    }
  }

  return .close
}

func handleAction(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
  if let shieldActionConfig = userDefaults?.dictionary(forKey: "shieldActions") {
    if let configForSelectedAction = shieldActionConfig[
      action == .primaryButtonPressed ? "primary" : "secondary"] as? [String: Any] {
      let response = handleAction(configForSelectedAction: configForSelectedAction)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        completionHandler(response)
      }
    } else {
      completionHandler(.close)
    }
  } else {
    completionHandler(.close)
  }
}

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  override func handle(
    action: ShieldAction, for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    logger.log("handle application")
    handleAction(action: action, completionHandler: completionHandler)
  }

  override func handle(
    action: ShieldAction, for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    logger.log("handle domain")
    handleAction(action: action, completionHandler: completionHandler)
  }

  override func handle(
    action: ShieldAction, for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    logger.log("handle category")
    handleAction(action: action, completionHandler: completionHandler)
  }
}
