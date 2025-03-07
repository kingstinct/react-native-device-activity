//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Robert Herber on 2024-10-25.
//

import FamilyControls
import ManagedSettings
import UIKit

func handleAction(
  configForSelectedAction: [String: Any],
  applicationToken: ApplicationToken?,
  webdomainToken: WebDomainToken?
) -> ShieldActionResponse {
  logger.log("handleAction")
  if let type = configForSelectedAction["type"] as? String {
    if type == "unblockAll" {
      unblockAllApps(triggeredBy: "shieldAction")
    }

    if type == "sendNotification" {
      // todo: replace with general string
      /*DispatchQueue.main.async(execute: {
        openUrl(urlString: "device-activity://")
      })

      notifyAppWithName(name: "fromShieldExtensions")

      sleep(ms: 1)*/

      if let payload = configForSelectedAction["payload"] as? [String: Any] {
        sendNotification(contents: payload, placeholders: [:])
      }
    }

    if type == "unblockCurrentApp" {
      let unblockedSelectionStr = userDefaults?.string(forKey: "unblockedSelection")

      var selection =
        unblockedSelectionStr != nil
        ? deserializeFamilyActivitySelection(familyActivitySelectionStr: unblockedSelectionStr!)
        : FamilyActivitySelection()

      if let applicationToken = applicationToken {
        selection.applicationTokens.insert(applicationToken)
      }

      if let webdomainToken = webdomainToken {
        selection.webDomainTokens.insert(webdomainToken)
      }

      let serialized = serializeFamilyActivitySelection(selection: selection)

      userDefaults?.set(serialized, forKey: "unblockedSelection")
    }
  }

  if let behavior = configForSelectedAction["behavior"] as? String {
    if behavior == "defer" {
      return .defer
    }
  }

  return .close
}

func handleAction(
  action: ShieldAction,
  completionHandler: @escaping (ShieldActionResponse) -> Void,
  applicationToken: ApplicationToken?,
  webdomainToken: WebDomainToken?
) {
  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

  if let shieldActionConfig = userDefaults?.dictionary(
    forKey: SHIELD_ACTIONS_KEY
  ) {
    if let configForSelectedAction = shieldActionConfig[
      action == .primaryButtonPressed ? "primary" : "secondary"] as? [String: Any] {
      let response = handleAction(
        configForSelectedAction: configForSelectedAction,
        applicationToken: applicationToken,
        webdomainToken: webdomainToken
      )
      if let delay = configForSelectedAction["delay"] as? Double {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          completionHandler(response)
        }
      } else {
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

    handleAction(
      action: action,
      completionHandler: completionHandler,
      applicationToken: application,
      webdomainToken: nil
    )
  }

  override func handle(
    action: ShieldAction, for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    logger.log("handle domain")

    handleAction(
      action: action,
      completionHandler: completionHandler,
      applicationToken: nil,
      webdomainToken: webDomain
    )
  }

  override func handle(
    action: ShieldAction, for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    logger.log("handle category")

    handleAction(
      action: action,
      completionHandler: completionHandler,
      applicationToken: nil,
      webdomainToken: nil
    )
  }
}
