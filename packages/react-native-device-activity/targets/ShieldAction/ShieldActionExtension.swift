//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Robert Herber on 2024-10-25.
//

import FamilyControls
import ManagedSettings
import UIKit

func handleShieldAction(
  configForSelectedAction: [String: Any],
  placeholders: [String: String?],
  applicationToken: ApplicationToken?,
  webdomainToken: WebDomainToken?,
  categoryToken: ActivityCategoryToken?
) -> ShieldActionResponse {
  logger.log("handleAction")
  if let actions = configForSelectedAction["actions"] as? [[String: Any]] {
    for action in actions {
      executeGenericAction(
        action: action,
        placeholders: placeholders,
        triggeredBy: "shieldAction",
        applicationToken: applicationToken,
        webdomainToken: webdomainToken,
        categoryToken: categoryToken
      )
    }
  }

  if let type = configForSelectedAction["type"] as? String {
    logger.log("type: \(type, privacy: .public)")
    if type == "disableBlockAllMode" {
      disableBlockAllMode(triggeredBy: "shieldAction")
    }

    let onlyFamilySelectionIdsContainingMonitoredActivityNames =
      configForSelectedAction["onlyFamilySelectionIdsContainingMonitoredActivityNames"] as? Bool
      ?? true

    let sortByGranularity = true

    if type == "unblockPossibleFamilyActivitySelection" {
      if let possibleFamilyActivitySelectionId = getPossibleFamilyActivitySelectionIds(
        applicationToken: applicationToken,
        webDomainToken: webdomainToken,
        categoryToken: categoryToken,
        onlyFamilySelectionIdsContainingMonitoredActivityNames:
          onlyFamilySelectionIdsContainingMonitoredActivityNames,
        sortByGranularity: sortByGranularity
      ).first?.id {
        if let selection = getFamilyActivitySelectionById(id: possibleFamilyActivitySelectionId) {
          unblockSelection(removeSelection: selection, triggeredBy: "shieldAction")
        }
      }
    }

    if type == "unblockAllPossibleFamilyActivitySelections" {
      let possibleFamilyActivitySelections = getPossibleFamilyActivitySelectionIds(
        applicationToken: applicationToken,
        webDomainToken: webdomainToken,
        categoryToken: categoryToken,
        onlyFamilySelectionIdsContainingMonitoredActivityNames:
          onlyFamilySelectionIdsContainingMonitoredActivityNames,
        sortByGranularity: sortByGranularity
      )

      for selection in possibleFamilyActivitySelections {
        unblockSelection(
          removeSelection: selection.selection,
          triggeredBy: "shieldAction"
        )
      }
    }

    if type == "whitelistPossibleFamilyActivitySelection" {
      if let possibleFamilyActivitySelectionId = getPossibleFamilyActivitySelectionIds(
        applicationToken: applicationToken,
        webDomainToken: webdomainToken,
        categoryToken: categoryToken,
        onlyFamilySelectionIdsContainingMonitoredActivityNames:
          onlyFamilySelectionIdsContainingMonitoredActivityNames,
        sortByGranularity: sortByGranularity
      ).first?.id {
        if let selection = getFamilyActivitySelectionById(id: possibleFamilyActivitySelectionId) {
          addSelectionToWhitelistAndUpdateBlock(
            whitelistSelection: selection,
            triggeredBy: "shieldAction"
          )
        }
      }
    }

    if type == "whitelistAllPossibleFamilyActivitySelections" {
      let possibleFamilyActivitySelections = getPossibleFamilyActivitySelectionIds(
        applicationToken: applicationToken,
        webDomainToken: webdomainToken,
        categoryToken: categoryToken,
        onlyFamilySelectionIdsContainingMonitoredActivityNames:
          onlyFamilySelectionIdsContainingMonitoredActivityNames,
        sortByGranularity: sortByGranularity
      )

      for selection in possibleFamilyActivitySelections {
        addSelectionToWhitelistAndUpdateBlock(
          whitelistSelection: selection.selection,
          triggeredBy: "shieldAction"
        )
      }
    }

    if type == "resetBlocks" {
      resetBlocks(triggeredBy: "shieldAction")
    }

    let url = configForSelectedAction["url"] as? String

    if type == "openUrl" {
      openUrl(urlString: url ?? "device-activity://")
    }

    if type == "openUrlWithDispatch" {
      DispatchQueue.main.async(execute: {
        openUrl(urlString: url ?? "device-activity://")
      })
    }

    if type == "sendNotification" {
      if let payload = configForSelectedAction["payload"] as? [String: Any] {
        sendNotification(contents: payload, placeholders: [:])
      }
    }

    if type == "addCurrentToWhitelist" {
      var selection = getCurrentWhitelist()

      if let applicationToken = applicationToken {
        selection.applicationTokens.insert(applicationToken)
      }

      if let webdomainToken = webdomainToken {
        selection.webDomainTokens.insert(webdomainToken)
      }

      if let categoryToken = categoryToken {
        selection.categoryTokens.insert(categoryToken)
      }

      saveCurrentWhitelist(whitelist: selection)
      updateBlock(triggeredBy: "shieldAction")
    }
  }

  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

  if let behavior = configForSelectedAction["behavior"] as? String {
    if behavior == "defer" {
      return .defer
    }
  }

  return .close
}

// MARK: - App name persistence
// Writes app/category/domain display names to shared UserDefaults so the main
// app can read them. Names are only available in extension contexts.

func stableTokenKey<T: Encodable>(for token: T) -> String? {
  guard let data = try? JSONEncoder().encode(token) else { return nil }
  return data.base64EncodedString()
}

func persistAppName(_ name: String?, forToken token: ApplicationToken?) {
  guard let name = name, let token = token,
    let key = stableTokenKey(for: token)
  else { return }
  var dict = userDefaults?.dictionary(forKey: "guardedAppNames") as? [String: String] ?? [:]
  dict[key] = name
  userDefaults?.set(dict, forKey: "guardedAppNames")
  userDefaults?.synchronize()
  logger.log("Persisted app name '\(name, privacy: .public)'")
}

func persistCategoryName(_ name: String?, forToken token: ActivityCategoryToken?) {
  guard let name = name, let token = token,
    let key = stableTokenKey(for: token)
  else { return }
  var dict = userDefaults?.dictionary(forKey: "guardedCategoryNames") as? [String: String] ?? [:]
  dict[key] = name
  userDefaults?.set(dict, forKey: "guardedCategoryNames")
  userDefaults?.synchronize()
  logger.log("Persisted category name '\(name, privacy: .public)'")
}

func persistWebDomainName(_ domain: String?, forToken token: WebDomainToken?) {
  guard let domain = domain, let token = token,
    let key = stableTokenKey(for: token)
  else { return }
  var dict = userDefaults?.dictionary(forKey: "guardedWebDomainNames") as? [String: String] ?? [:]
  dict[key] = domain
  userDefaults?.set(dict, forKey: "guardedWebDomainNames")
  userDefaults?.synchronize()
  logger.log("Persisted web domain '\(domain, privacy: .public)'")
}

func handleAction(
  action: ShieldAction,
  completionHandler: @escaping (ShieldActionResponse) -> Void,
  applicationToken: ApplicationToken?,
  webdomainToken: WebDomainToken?,
  categoryToken: ActivityCategoryToken?
) {
  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

  // Persist display names to shared UserDefaults for the main app
  if let applicationToken = applicationToken {
    persistAppName(
      Application(token: applicationToken).localizedDisplayName, forToken: applicationToken)
  }
  if let webdomainToken = webdomainToken {
    persistWebDomainName(WebDomain(token: webdomainToken).domain, forToken: webdomainToken)
  }
  if let categoryToken = categoryToken {
    persistCategoryName(
      ActivityCategory(token: categoryToken).localizedDisplayName, forToken: categoryToken)
  }

  if let shieldActionConfig = getActivitySelectionPrefixedConfigFromUserDefaults(
    keyPrefix: SHIELD_ACTIONS_FOR_SELECTION_PREFIX,
    fallbackKey: SHIELD_ACTIONS_KEY,
    applicationToken: applicationToken,
    webDomainToken: webdomainToken,
    categoryToken: categoryToken
  ) {
    let actionButton = action == .primaryButtonPressed ? "primary" : "secondary"
    let familyActivitySelectionId = getPossibleFamilyActivitySelectionIds(
      applicationToken: applicationToken,
      webDomainToken: webdomainToken,
      categoryToken: categoryToken,
      onlyFamilySelectionIdsContainingMonitoredActivityNames: true,
      sortByGranularity: true
    ).first
    if let configForSelectedAction = shieldActionConfig[actionButton] as? [String: Any] {
      let placeholders: [String: String?] = [
        "action": actionButton,
        "applicationName": applicationToken != nil
          ? Application(token: applicationToken!).localizedDisplayName : nil,
        "webDomain": webdomainToken != nil
          ? WebDomain(
            token: webdomainToken!
          ).domain : nil,
        "familyActivitySelectionId": familyActivitySelectionId?.id,
      ]

      let response = handleShieldAction(
        configForSelectedAction: configForSelectedAction,
        placeholders: placeholders,
        applicationToken: applicationToken,
        webdomainToken: webdomainToken,
        categoryToken: categoryToken
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
      webdomainToken: nil,
      categoryToken: nil
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
      webdomainToken: webDomain,
      categoryToken: nil
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
      webdomainToken: nil,
      categoryToken: category
    )
  }
}
