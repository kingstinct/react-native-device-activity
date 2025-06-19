//
//  Utils.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-07.
//

import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import UIKit
import WebKit
import os

let FALLBACK_SHIELD_CONFIGURATION_KEY = "shieldConfiguration"
let SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX = "shieldConfigurationForSelection"
let SHIELD_ACTIONS_FOR_SELECTION_PREFIX = "shieldActionsForSelection"
let SHIELD_ACTIONS_KEY = "shieldActions"
let CURRENT_BLOCKLIST_KEY = "currentBlockedSelection"
let CURRENT_WHITELIST_KEY = "currentUnblockedSelection"
let IS_BLOCKING_ALL = "isBlockingAll"
let FAMILY_ACTIVITY_SELECTION_ID_KEY = "familyActivitySelectionIds"

let appGroup =
  Bundle.main.object(forInfoDictionaryKey: "REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP") as? String
var userDefaults = UserDefaults(suiteName: appGroup)

@available(iOS 14.0, *)
let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

var task: URLSessionDataTask?

@available(iOS 15.0, *)
func updateShield(shieldId: String?, triggeredBy: String?, activitySelectionId: String?) {
  let shieldId = shieldId ?? "default"

  if var shieldConfiguration = userDefaults?.dictionary(
    forKey: "shieldConfiguration_\(shieldId)") {

    shieldConfiguration["shieldId"] = shieldId
    shieldConfiguration["triggeredBy"] = triggeredBy
    shieldConfiguration["updatedAt"] = Date().ISO8601Format()

    // update default shield
    userDefaults?.set(shieldConfiguration, forKey: FALLBACK_SHIELD_CONFIGURATION_KEY)
    if let activitySelectionId = activitySelectionId {
      userDefaults?.set(
        shieldConfiguration,
        forKey: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX + "_" + activitySelectionId)
    }
  }

  if var shieldActions = userDefaults?.dictionary(
    forKey: "shieldActions_\(shieldId)") {

    shieldActions["shieldId"] = shieldId
    shieldActions["triggeredBy"] = triggeredBy
    shieldActions["updatedAt"] = Date().ISO8601Format()

    userDefaults?.set(shieldActions, forKey: SHIELD_ACTIONS_KEY)

    if let activitySelectionId = activitySelectionId {
      userDefaults?
        .set(
          shieldActions,
          forKey: SHIELD_ACTIONS_FOR_SELECTION_PREFIX + "_" + activitySelectionId
        )
    }
  }
}

func sleep(ms: Int) {
  let delay = DispatchTimeInterval.milliseconds(ms)
  let group = DispatchGroup()
  group.enter()
  _ = group.wait(timeout: .now() + delay)
}

func openUrl(urlString: String) {
  guard let url = URL(string: urlString) else {
    return  // be safe
  }

  let context = NSExtensionContext()
  context.open(url) { _ in

  }
}

let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()

func notifyAppWithName(name: String) {
  let notificationName = CFNotificationName(name as CFString)

  CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, false)
}

func executeGenericAction(
  action: [String: Any],
  placeholders: [String: String?],
  triggeredBy: String,
  applicationToken: ApplicationToken? = nil,
  webdomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil
) {
  let type = action["type"] as? String

  if let sleepBefore = action["sleepBefore"] as? Int {
    sleep(ms: sleepBefore)
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

  if type == "blockSelection" {
    if let familyActivitySelectionId = action["familyActivitySelectionId"] as? String {
      if let activitySelection = getFamilyActivitySelectionById(id: familyActivitySelectionId) {
        updateShield(
          shieldId: action["shieldId"] as? String,
          triggeredBy: triggeredBy,
          activitySelectionId: familyActivitySelectionId
        )

        sleep(ms: 50)

        blockSelectedApps(
          blockSelection: activitySelection,
          triggeredBy: triggeredBy
        )
      } else {
        logger.log(
          "No familyActivitySelection found with ID: \(familyActivitySelectionId, privacy: .public)"
        )
      }
    }
  } else if type == "unblockSelection" {
    if let familyActivitySelectionId = action["familyActivitySelectionId"] as? String {
      if let activitySelection = getFamilyActivitySelectionById(id: familyActivitySelectionId) {

        unblockSelection(
          removeSelection: activitySelection,
          triggeredBy: triggeredBy
        )

        userDefaults?
          .removeObject(
            forKey: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX + "_" + familyActivitySelectionId)
      }
    }
  } else if type == "addSelectionToWhitelist" {
    if let familyActivitySelectionInput = action["familyActivitySelection"] as? [String: Any] {
      let selection = parseActivitySelectionInput(input: familyActivitySelectionInput)
      addSelectionToWhitelistAndUpdateBlock(
        whitelistSelection: selection,
        triggeredBy: triggeredBy
      )
    }
  } else if type == "removeSelectionFromWhitelist" {
    if let familyActivitySelectionInput = action["familyActivitySelection"] as? [String: Any] {
      let selection = parseActivitySelectionInput(input: familyActivitySelectionInput)
      removeSelectionFromWhitelistAndUpdateBlock(
        selection: selection,
        triggeredBy: triggeredBy
      )
    }
  } else if type == "clearWhitelistAndUpdateBlock" {
    logger.info("should clearWhitelistAndUpdateBlock")
    clearWhitelist()
    updateBlock(triggeredBy: triggeredBy)
    logger.info("done")
  } else if type == "resetBlocks" {
    resetBlocks(triggeredBy: triggeredBy)
  } else if type == "clearWhitelist" {
    clearWhitelist()
  } else if type == "disableBlockAllMode" {
    disableBlockAllMode(triggeredBy: triggeredBy)
  } else if type == "openApp" {
    // todo: replace with general string
    openUrl(urlString: "device-activity://")

    sleep(ms: 1000)
  } else if type == "enableBlockAllMode" {
    updateShield(
      shieldId: action["shieldId"] as? String,
      triggeredBy: triggeredBy,
      activitySelectionId: nil
    )

    // sometimes the shield doesn't pick up the shield config change above, trying a sleep to get around it
    sleep(ms: 50)

    enableBlockAllMode(triggeredBy: triggeredBy)
  } else if type == "removeAllPendingNotificationRequests" {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  } else if type == "removeAllDeliveredNotifications" {
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  } else if type == "removePendingNotificationRequests" {
    if let identifiers = action["identifiers"] as? [String] {
      UNUserNotificationCenter
        .current()
        .removePendingNotificationRequests(withIdentifiers: identifiers)
    }
  } else if type == "setBadgeCount" {
    let actionWithReplacedPlaceholders = replacePlaceholdersInObject(action, with: placeholders)
    if let count = actionWithReplacedPlaceholders["count"] as? Int {
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter
          .current()
          .setBadgeCount(count)
      }
    }
  } else if type == "sendNotification" {
    if let notification = action["payload"] as? [String: Any] {
      sendNotification(contents: notification, placeholders: placeholders)
    }
  } else if type == "sendHttpRequest" {
    if let url = action["url"] as? String {
      let config = action["options"] as? [String: Any] ?? [:]

      task = sendHttpRequest(with: url, config: config, placeholders: placeholders)

      // required for it to have time to trigger before process/callback ends
      sleep(ms: 1000)
    }
  } else if type == "startMonitoring" {
    if let activityName = action["activityName"] as? String,
      let deviceActivityEvents = action["deviceActivityEvents"] as? [[String: Any]] {

      startMonitoringAction(
        activityName: activityName,
        deviceActivityEvents: deviceActivityEvents,
        intervalStartDelayMs: action["intervalStartDelayMs"] as? Int,
        intervalEndDelayMs: action["intervalEndDelayMs"] as? Int,
        triggeredBy: triggeredBy
      )
    }
  } else if type == "stopMonitoring" {
    let activityNames = action["activityNames"] as? [String]

    stopMonitoringAction(
      activityNames: activityNames,
      triggeredBy: triggeredBy
    )
  }

  if let sleepAfter = action["sleepAfter"] as? Int {
    sleep(ms: sleepAfter)
  }
}

func sendNotification(contents: [String: Any], placeholders: [String: String?]) {
  let content = UNMutableNotificationContent()

  if let title = contents["title"] as? String {
    content.title = replacePlaceholders(title, with: placeholders)
  }

  if let subtitle = contents["subtitle"] as? String {
    content.subtitle = replacePlaceholders(subtitle, with: placeholders)
  }

  if let body = contents["body"] as? String {
    content.body = replacePlaceholders(body, with: placeholders)
  }

  if let sound = contents["sound"] as? String {
    if sound == "default" {
      content.sound = .default
    }
    if sound == "defaultCritical" {
      content.sound = .defaultCritical
    }
    if #available(iOS 15.2, *) {
      if sound == "defaultRingtone" {
        content.sound = .defaultRingtone
      }
    }
  }

  if let categoryIdentifier = contents["categoryIdentifier"] as? String {
    content.categoryIdentifier = categoryIdentifier
  }

  if let badge = contents["badge"] as? NSNumber {
    content.badge = badge
  }

  if let userInfo = contents["userInfo"] as? [String: Any] {
    content.userInfo = userInfo
  }

  if #available(iOS 15.0, *) {
    if let interruptionLevel = contents["interruptionLevel"] as? String {
      if interruptionLevel == "active" {
        content.interruptionLevel = .active
      }

      if interruptionLevel == "critical" {
        content.interruptionLevel = .critical
      }

      if interruptionLevel == "passive" {
        content.interruptionLevel = .passive
      }

      if interruptionLevel == "timeSensitive" {
        content.interruptionLevel = .timeSensitive
      }
    }
  }

  if let threadIdentifier = contents["threadIdentifier"] as? String {
    content.threadIdentifier = threadIdentifier
  }

  if let launchImageName = contents["launchImageName"] as? String {
    content.launchImageName = launchImageName
  }

  let identifier = contents["identifier"] as? String ?? UUID().uuidString

  let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

  UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

// dataRequest which sends request to given URL and convert to Decodable Object
func sendHttpRequest(with url: String, config: [String: Any], placeholders: [String: String?])
  -> URLSessionDataTask {
  // create the URL
  let url = URL(string: url)!  // change the URL

  // create the session object
  let session = URLSession.shared

  // Now create the URLRequest object using the URL object
  var request = URLRequest(url: url)

  if let httpMethod = config["httpMethod"] as? String {
    request.httpMethod = httpMethod
  }

  if let body = config["body"] as? [String: Any] {
    let bodyWithPlaceholders = replacePlaceholdersInObject(body, with: placeholders)
    request.httpBody = try? JSONSerialization.data(
      withJSONObject: bodyWithPlaceholders, options: .prettyPrinted)
  }

  if let headers = config["headers"] as? [String: String] {
    let headersWithPlaceholders = replacePlaceholdersInObject(headers, with: placeholders)
    // merge with existing headers
    request.allHTTPHeaderFields = request.allHTTPHeaderFields?.merging(
      headersWithPlaceholders, uniquingKeysWith: { $1 })
  }

  // create dataTask using the session object to send data to the server
  let task = session.dataTask(
    with: request,
    completionHandler: { data, _, error in

      guard error == nil else {
        return
      }

      guard let data = data else {
        return
      }

      do {
        // create json object from data
        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
          as? [String: Any] {
          print(json)
        }
      } catch let error {
        print(error.localizedDescription)
      }
    })

  task.resume()

  return task
}

@available(iOS 15.0, *)
struct FamilyActivitySelectionWithId {
  var selection: FamilyActivitySelection
  var id: String
}

@available(iOS 15.0, *)
struct FamilyActivitySelectionWithIdWithMatching {
  init(
    selection: FamilyActivitySelection,
    id: String,
    granularMatch: Bool,
    match: Bool,
    granularityCount: Int
  ) {
    self.selection = selection
    self.id = id
    self.granularMatch = granularMatch
    self.match = match
    self.granularityCount = granularityCount
  }

  init(
    selection: FamilyActivitySelectionWithId,
    granularMatch: Bool,
    match: Bool,
    granularityCount: Int
  ) {
    self.selection = selection.selection
    self.id = selection.id
    self.granularMatch = granularMatch
    self.match = match
    self.granularityCount = granularityCount
  }

  var selection: FamilyActivitySelection
  var id: String
  // indicates that the match is directly on the webDomain or application
  var granularMatch: Bool
  var match: Bool
  var granularityCount: Int
}

struct TextToReplaceWithOptionalSpecialTreatment {
  var textToReplace: String
  var specialTreatment: String?
}

func getTextToReplaceWithOptionalSpecialTreatment(_ stringToReplace: String)
  -> TextToReplaceWithOptionalSpecialTreatment {
  if stringToReplace.starts(with: "{") && stringToReplace.hasSuffix("}")
    && stringToReplace.contains(":") {
    // remove prefix and suffix
    let trimmed = String(stringToReplace.dropFirst().dropLast())
    // split on : and return first part
    let prefixAndPlaceholder = trimmed.split(separator: ":")
    return TextToReplaceWithOptionalSpecialTreatment(
      textToReplace: String(prefixAndPlaceholder[1]),
      specialTreatment: String(prefixAndPlaceholder[0]))
  }

  return TextToReplaceWithOptionalSpecialTreatment(
    textToReplace: stringToReplace
  )
}

func replacePlaceholdersInObject<T: Any>(
  _ object: [String: T], with placeholders: [String: String?]
) -> [String: T] {
  var retVal = object

  for (key, value) in object {
    if let value = value as? String {
      let textToReplaceWithOptionalSpecialTreatment = getTextToReplaceWithOptionalSpecialTreatment(
        value)
      if let specialTreatment = textToReplaceWithOptionalSpecialTreatment.specialTreatment {
        if specialTreatment == "asNumber" {
          if let placeholderValue = placeholders[
            textToReplaceWithOptionalSpecialTreatment.textToReplace] as? String {
            if let numberValue = Double(placeholderValue) {
              retVal[key] = numberValue as? T
            }
          }
        }
        if specialTreatment == "userDefaults" {
          if let value = userDefaults?.string(
            forKey: textToReplaceWithOptionalSpecialTreatment.textToReplace) {
            retVal[key] = value as? T
          }
        }
      } else {
        retVal[key] = replacePlaceholders(value, with: placeholders) as? T
      }
    }
  }

  return retVal
}

func replacePlaceholders(_ text: String, with placeholders: [String: String?]) -> String {
  let retVal = placeholders.reduce(text) { text, placeholder in
    text.replacingOccurrences(
      of: "{" + placeholder.key + "}", with: placeholder.value ?? placeholder.key)
  }

  return retVal
}

@available(iOS 15.0, *)
var store = ManagedSettingsStore()

@available(iOS 15.0, *)
func refreshManagedSettingsStore() {
  store = ManagedSettingsStore()
}

@available(iOS 16.0, *)
func clearAllManagedSettingsStoreSettings() {
  store.clearAllSettings()
}

@available(iOS 15.0, *)
func getFamilyActivitySelectionIds() -> [FamilyActivitySelectionWithId] {
  if let familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: "familyActivitySelectionIds") {
    return familyActivitySelectionIds.compactMap { (key: String, value: Any) in
      if let familyActivitySelectionStr = value as? String {
        let activitySelection = deserializeFamilyActivitySelection(
          familyActivitySelectionStr: familyActivitySelectionStr)

        return FamilyActivitySelectionWithId(selection: activitySelection, id: key)
      }
      return nil
    }
  }
  return []
}

@available(iOS 15.0, *)
func getFamilyActivitySelectionById(id: String) -> FamilyActivitySelection? {
  if let familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY) {
    if let familyActivitySelectionStr = familyActivitySelectionIds[id] as? String {
      let activitySelection = deserializeFamilyActivitySelection(
        familyActivitySelectionStr: familyActivitySelectionStr
      )
      return activitySelection
    }
  }
  return nil
}

func removeFamilyActivitySelectionById(id: String) {
  if var familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY) {
    familyActivitySelectionIds.removeValue(forKey: id)

    userDefaults?
      .set(familyActivitySelectionIds, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  }
}

@available(iOS 15.0, *)
func setFamilyActivitySelectionById(id: String, activitySelection: FamilyActivitySelection) {
  let serialized = serializeFamilyActivitySelection(
    selection: activitySelection
  )

  if var familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY) {
    familyActivitySelectionIds[id] = serialized

    userDefaults?
      .set(familyActivitySelectionIds, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  } else {
    let dict = [
      id: serialized
    ]
    userDefaults?.set(dict, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  }
}

@available(iOS 15.0, *)
func renameFamilyActivitySelectionId(previousId: String, newId: String) {
  if var familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY) {
    familyActivitySelectionIds[newId] = familyActivitySelectionIds[previousId]
    familyActivitySelectionIds.removeValue(forKey: previousId)

    userDefaults?
      .set(familyActivitySelectionIds, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  }
}

@available(iOS 15.0, *)
func tryGetActivitySelectionIdConfigKey(
  keyPrefix: String,
  applicationToken: ApplicationToken? = nil,
  webDomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil,
  onlyFamilySelectionIdsContainingMonitoredActivityNames: Bool = true
) -> String? {
  let familyActivitySelectionIds = getPossibleFamilyActivitySelectionIds(
    applicationToken: applicationToken,
    webDomainToken: webDomainToken,
    categoryToken: categoryToken,
    onlyFamilySelectionIdsContainingMonitoredActivityNames:
      onlyFamilySelectionIdsContainingMonitoredActivityNames,
    sortByGranularity: true
  )

  let activitySelection = familyActivitySelectionIds.first {
    (activitySelectionPair) in
    return userDefaults?.dictionary(
      forKey: keyPrefix + "_" + activitySelectionPair.id
    ) != nil
  }

  return activitySelection != nil ? keyPrefix + "_" + activitySelection!.id : nil
}

@available(iOS 15.0, *)
func getActivitySelectionPrefixedConfigFromUserDefaults(
  keyPrefix: String,
  fallbackKey: String,
  applicationToken: ApplicationToken? = nil,
  webDomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil
) -> [String: Any]? {
  if let configKey = tryGetActivitySelectionIdConfigKey(
    keyPrefix: keyPrefix,
    applicationToken: applicationToken,
    webDomainToken: webDomainToken,
    categoryToken: categoryToken
  ) {
    if let config = userDefaults?.dictionary(forKey: configKey) {
      return config
    }
  }

  return userDefaults?.dictionary(forKey: fallbackKey)
}

@available(iOS 15.0, *)
var center = DeviceActivityCenter()

@available(iOS 15.0, *)
func getPossibleFamilyActivitySelectionIds(
  applicationToken: ApplicationToken? = nil,
  webDomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil,
  onlyFamilySelectionIdsContainingMonitoredActivityNames: Bool = true,
  sortByGranularity: Bool = true
) -> [FamilyActivitySelectionWithIdWithMatching] {
  let familyActivitySelectionIds = getFamilyActivitySelectionIds()
  let monitoredActivities =
    onlyFamilySelectionIdsContainingMonitoredActivityNames ? center.activities : []

  let idsWithMatchings = familyActivitySelectionIds.map({ (activitySelection) in
    if onlyFamilySelectionIdsContainingMonitoredActivityNames {
      let isActivityMonitored = monitoredActivities.contains(where: {
        return $0.self.rawValue.contains(activitySelection.id)
      })

      if !isActivityMonitored {
        return FamilyActivitySelectionWithIdWithMatching(
          selection: activitySelection,
          granularMatch: false,
          match: false,
          granularityCount: 0
        )
      }
    }

    if let applicationToken = applicationToken {
      if activitySelection.selection.applicationTokens.contains(applicationToken) {
        return FamilyActivitySelectionWithIdWithMatching(
          selection: activitySelection,
          granularMatch: true,
          match: true,
          granularityCount: activitySelection.selection.applicationTokens.count
        )
      }
    }

    if let webDomainToken = webDomainToken {
      if activitySelection.selection.webDomainTokens.contains(webDomainToken) {
        return FamilyActivitySelectionWithIdWithMatching(
          selection: activitySelection,
          granularMatch: true,
          match: true,
          granularityCount: activitySelection.selection.webDomainTokens.count
        )
      }
    }

    if let categoryToken = categoryToken {
      if activitySelection.selection.categoryTokens.contains(categoryToken) {
        return FamilyActivitySelectionWithIdWithMatching(
          selection: activitySelection,
          granularMatch: false,
          match: true,
          granularityCount: activitySelection.selection.categoryTokens.count
        )
      }
    }

    return FamilyActivitySelectionWithIdWithMatching(
      selection: activitySelection,
      granularMatch: false,
      match: false,
      granularityCount: 0
    )
  })

  let ids = idsWithMatchings.filter({ (activitySelection) in
    return activitySelection.match
  })

  return ids.sorted { selection1, selection2 in
    if selection1.granularMatch != selection2.granularMatch {
      return selection1.granularMatch && !selection2.granularMatch
    }
    return selection1.granularityCount < selection2.granularityCount
  }
}

@available(iOS 15.0, *)
func deserializeFamilyActivitySelection(familyActivitySelectionStr: String)
  -> FamilyActivitySelection {
  var activitySelection = FamilyActivitySelection()

  let decoder = JSONDecoder()
  let data = Data(base64Encoded: familyActivitySelectionStr)
  do {
    activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
  } catch {
    logger.log("decode error \(error.localizedDescription, privacy: .public)")
  }

  return activitySelection
}

@available(iOS 15.0, *)
func serializeFamilyActivitySelection(selection: FamilyActivitySelection) -> String {
  let encoder = JSONEncoder()
  do {
    let json = try encoder.encode(selection)
    let jsonString = json.base64EncodedString()

    return jsonString
  } catch {
    return ""
  }
}

@available(iOS 15.0, *)
func enableBlockAllMode(triggeredBy: String) {
  userDefaults?.set(true, forKey: IS_BLOCKING_ALL)

  updateBlock(triggeredBy: triggeredBy)
}

@available(iOS 15.0, *)
func disableBlockAllMode(triggeredBy: String) {
  userDefaults?
    .removeObject(forKey: IS_BLOCKING_ALL)

  updateBlock(triggeredBy: triggeredBy)
}

@available(iOS 15.0, *)
func setsIncludesEntireCategory(
  _ selection1: FamilyActivitySelection, _ selection2: FamilyActivitySelection
)
  -> Bool {
  if #available(iOS 15.2, *) {
    let selection1Safe = selection1.includeEntireCategory || selection1.categoryTokens.count == 0

    let selection2Safe = selection2.includeEntireCategory || selection2.categoryTokens.count == 0

    return selection1Safe && selection2Safe
  }

  return false
}

@available(iOS 15.0, *)
func intersection(_ selection1: FamilyActivitySelection, _ selection2: FamilyActivitySelection)
  -> FamilyActivitySelection {
  let applicationTokens = selection1.applicationTokens.intersection(
    selection2.applicationTokens
  )

  let domainTokens = selection1.webDomainTokens.intersection(
    selection2.webDomainTokens
  )

  let categoryTokens = selection1.categoryTokens.intersection(
    selection2.categoryTokens
  )

  let includeEntireCategory = setsIncludesEntireCategory(
    selection1,
    selection2
  )

  var selection = FamilyActivitySelection(
    includeEntireCategory: includeEntireCategory
  )

  selection.applicationTokens = applicationTokens
  selection.webDomainTokens = domainTokens
  selection.categoryTokens = categoryTokens

  return selection
}

@available(iOS 15.0, *)
func symmetricDifference(
  _ selection1: FamilyActivitySelection, _ selection2: FamilyActivitySelection
) -> FamilyActivitySelection {
  let applicationTokens = selection1.applicationTokens.symmetricDifference(
    selection2.applicationTokens
  )

  let domainTokens = selection1.webDomainTokens.symmetricDifference(
    selection2.webDomainTokens
  )

  let categoryTokens = selection1.categoryTokens.symmetricDifference(
    selection2.categoryTokens
  )

  let includeEntireCategory = setsIncludesEntireCategory(
    selection1,
    selection2
  )

  var selection = FamilyActivitySelection(
    includeEntireCategory: includeEntireCategory
  )

  selection.applicationTokens = applicationTokens
  selection.webDomainTokens = domainTokens
  selection.categoryTokens = categoryTokens

  return selection
}

@available(iOS 15.0, *)
func difference(_ selection1: FamilyActivitySelection, _ selection2: FamilyActivitySelection)
  -> FamilyActivitySelection {
  let applicationTokens = selection1.applicationTokens.subtracting(
    selection2.applicationTokens
  )

  let domainTokens = selection1.webDomainTokens.subtracting(
    selection2.webDomainTokens
  )

  let categoryTokens = selection1.categoryTokens.subtracting(
    selection2.categoryTokens
  )

  let includeEntireCategory = setsIncludesEntireCategory(
    selection1,
    selection2
  )

  var selection = FamilyActivitySelection(
    includeEntireCategory: includeEntireCategory
  )

  selection.applicationTokens = applicationTokens
  selection.webDomainTokens = domainTokens
  selection.categoryTokens = categoryTokens

  return selection
}

@available(iOS 15.0, *)
func union(_ selection1: FamilyActivitySelection, _ selection2: FamilyActivitySelection)
  -> FamilyActivitySelection {
  let applicationTokens = selection1.applicationTokens.union(
    selection2.applicationTokens
  )

  let domainTokens = selection1.webDomainTokens.union(
    selection2.webDomainTokens
  )

  let categoryTokens = selection1.categoryTokens.union(
    selection2.categoryTokens
  )

  let includeEntireCategory = setsIncludesEntireCategory(
    selection1,
    selection2
  )

  var selection = FamilyActivitySelection(
    includeEntireCategory: includeEntireCategory
  )

  selection.applicationTokens = applicationTokens
  selection.webDomainTokens = domainTokens
  selection.categoryTokens = categoryTokens

  return selection
}

@available(iOS 15.0, *)
func parseActivitySelectionInput(input: [String: Any]) -> FamilyActivitySelection {
  if let currentBlocklist = input["currentBlocklist"] as? Bool {
    if currentBlocklist {
      return getCurrentBlocklist()
    }
  }
  if let currentWhitelist = input["currentWhitelist"] as? Bool {
    if currentWhitelist {
      return getCurrentWhitelist()
    }
  }
  if let activitySelectionId = input["activitySelectionId"] as? String {
    if let selection = getFamilyActivitySelectionById(id: activitySelectionId) {
      return selection
    }
  }

  if let activitySelectionToken = input["activitySelectionToken"] as? String {
    return deserializeFamilyActivitySelection(
      familyActivitySelectionStr: activitySelectionToken
    )
  }

  return FamilyActivitySelection()
}

@available(iOS 15.0, *)
func getCurrentWhitelist() -> FamilyActivitySelection {
  let currentWhitelistSelectionSerialized = userDefaults?
    .string(forKey: CURRENT_WHITELIST_KEY)

  if let currentWhitelistSelectionSerialized = currentWhitelistSelectionSerialized {
    return deserializeFamilyActivitySelection(
      familyActivitySelectionStr: currentWhitelistSelectionSerialized)
  }

  return FamilyActivitySelection()
}

@available(iOS 15.0, *)
func isShieldActive() -> Bool {
  let shield = store.shield

  let applications = shield.applications ?? Set()
  let webDomains = shield.webDomains ?? Set()

  let areAnyApplicationsShielded = applications.count > 0
  let areAnyWebDomainsShielded = webDomains.count > 0
  let areAnyApplicationCategoriesShielded =
    shield.applicationCategories != nil
    && shield.applicationCategories
      != ShieldSettings.ActivityCategoryPolicy<Application>.none
    && shield.applicationCategories
      != ShieldSettings.ActivityCategoryPolicy<Application>.specific(Set(), except: Set())
  let areAnyWebDomainCategoriesShielded =
    shield.webDomainCategories != nil
    && shield.webDomainCategories != ShieldSettings.ActivityCategoryPolicy<WebDomain>.none
    && shield.webDomainCategories
      != ShieldSettings.ActivityCategoryPolicy<WebDomain>
      .specific(Set(), except: Set())

  return areAnyApplicationsShielded
    || areAnyWebDomainsShielded
    || areAnyApplicationCategoriesShielded
    || areAnyWebDomainCategoriesShielded
}

@available(iOS 15.0, *)
func clearWhitelist() {
  userDefaults?
    .removeObject(forKey: CURRENT_WHITELIST_KEY)
}

@available(iOS 15.0, *)
func resetBlocks(triggeredBy: String) {
  userDefaults?
    .removeObject(forKey: CURRENT_BLOCKLIST_KEY)

  updateBlock(triggeredBy: triggeredBy)
}

@available(iOS 15.0, *)
func getCurrentBlocklist() -> FamilyActivitySelection {
  let currentBlockedSelectionSerialized = userDefaults?
    .string(forKey: CURRENT_BLOCKLIST_KEY)

  if let currentBlockedSelectionSerialized = currentBlockedSelectionSerialized {
    return deserializeFamilyActivitySelection(
      familyActivitySelectionStr: currentBlockedSelectionSerialized)
  }

  return FamilyActivitySelection()
}

func isBlockingAllModeEnabled() -> Bool {
  let isBlockingAll = userDefaults?.bool(forKey: IS_BLOCKING_ALL) ?? false

  return isBlockingAll
}

@available(iOS 15.0, *)
func saveCurrentBlocklist(blocklist: FamilyActivitySelection) {
  userDefaults?
    .set(
      serializeFamilyActivitySelection(selection: blocklist),
      forKey: CURRENT_BLOCKLIST_KEY
    )
}

@available(iOS 15.0, *)
func saveCurrentWhitelist(whitelist: FamilyActivitySelection) {
  userDefaults?
    .set(
      serializeFamilyActivitySelection(selection: whitelist),
      forKey: CURRENT_WHITELIST_KEY
    )
}

@available(iOS 15.0, *)
func addSelectionToWhitelistAndUpdateBlock(
  whitelistSelection: FamilyActivitySelection,
  triggeredBy: String
) {
  let currentWhitelist = getCurrentWhitelist()

  let updatedWhitelist = union(whitelistSelection, currentWhitelist)

  saveCurrentWhitelist(whitelist: updatedWhitelist)

  updateBlock(triggeredBy: triggeredBy)
}

struct WhitelistSelectionWithoutEntireCategoryError: Error {

}

struct TryingToBlockSelectionWhenBlockModeIsEnabledError: Error {

}

@available(iOS 15.0, *)
func removeSelectionFromWhitelistAndUpdateBlock(
  selection: FamilyActivitySelection,
  triggeredBy: String
) {
  let currentWhitelist = getCurrentWhitelist()

  let updatedWhitelist = difference(currentWhitelist, selection)

  saveCurrentWhitelist(whitelist: updatedWhitelist)

  updateBlock(triggeredBy: triggeredBy)
}

@available(iOS 15.0, *)
func blockSelectedApps(
  blockSelection: FamilyActivitySelection,
  triggeredBy: String
) {
  let currentBlocklist = getCurrentBlocklist()

  let updatedBlocklist = union(blockSelection, currentBlocklist)

  saveCurrentBlocklist(blocklist: updatedBlocklist)

  updateBlock(triggeredBy: triggeredBy)
}

@available(iOS 15.0, *)
func updateBlock(triggeredBy: String) {
  let blockingAllModeEnabled = isBlockingAllModeEnabled()
  let currentBlocklist = getCurrentBlocklist()
  let currentWhitelist = getCurrentWhitelist()

  userDefaults?.set(
    [
      "triggeredBy": triggeredBy,
      "blockedAt": Date.now.ISO8601Format(),
      "blockingAllModeEnabled": blockingAllModeEnabled,
      "blocklistAppCount": currentBlocklist.applicationTokens.count,
      "blocklistWebDomainCount": currentBlocklist.webDomainTokens.count,
      "blocklistCategoryCount": currentBlocklist.categoryTokens.count,
      "whitelistAppCount": currentWhitelist.applicationTokens.count,
      "whitelistWebDomainCount": currentWhitelist.webDomainTokens.count,
      "whitelistCategoryCount": currentWhitelist.categoryTokens.count
    ], forKey: "lastBlockUpdate")

  updateBlockInternal(
    isBlockingAllModeEnabled: blockingAllModeEnabled,
    currentBlocklist: currentBlocklist,
    currentWhitelist: currentWhitelist
  )
}

@available(iOS 15.0, *)
func updateBlockInternal(
  isBlockingAllModeEnabled: Bool,
  currentBlocklist: FamilyActivitySelection,
  currentWhitelist: FamilyActivitySelection
) {
  if isBlockingAllModeEnabled {
    store.shield.applicationCategories = .all(
      except: currentWhitelist.applicationTokens
    )
    store.shield.webDomainCategories = .all(
      except: currentWhitelist.webDomainTokens
    )

    return
  }

  let blocklistWithoutWhiteListOverlap: FamilyActivitySelection = difference(
    currentBlocklist,
    currentWhitelist
  )

  store.shield.applications = blocklistWithoutWhiteListOverlap.applicationTokens

  store.shield.webDomains = blocklistWithoutWhiteListOverlap.webDomainTokens

  if blocklistWithoutWhiteListOverlap.categoryTokens.count > 0 {
    store.shield.applicationCategories = .specific(
      blocklistWithoutWhiteListOverlap.categoryTokens,
      except: currentWhitelist.applicationTokens
    )
    store.shield.webDomainCategories = .specific(
      blocklistWithoutWhiteListOverlap.categoryTokens,
      except: currentWhitelist.webDomainTokens
    )
  } else {
    store.shield.applicationCategories = nil
    store.shield.webDomainCategories = nil
  }
}

@available(iOS 15.0, *)
func unblockSelection(
  removeSelection: FamilyActivitySelection,
  triggeredBy: String
) {
  let currentBlocklist = getCurrentBlocklist()

  let updatedBlocklist = difference(currentBlocklist, removeSelection)

  saveCurrentBlocklist(blocklist: updatedBlocklist)

  updateBlock(triggeredBy: triggeredBy)
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

func userDefaultKeyForEvent(activityName: String, callbackName: String, eventName: String? = nil)
  -> String {

  let fullEventName =
    eventName == nil
    ? "events_\(activityName)_\(callbackName)"
    : "events_\(activityName)_\(callbackName)_\(eventName!)"

  return fullEventName
}

func persistToUserDefaults(activityName: String, callbackName: String, eventName: String? = nil) {
  let now = (Date().timeIntervalSince1970 * 1000).rounded()

  let fullEventName = userDefaultKeyForEvent(
    activityName: activityName,
    callbackName: callbackName,
    eventName: eventName
  )

  userDefaults?.set(now, forKey: fullEventName)

  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
}

func isHigherEvent(eventName: String, higherThan: String) -> Bool {
  if let eventNameNum = Double(eventName), let higherThanNum = Double(higherThan) {
    return eventNameNum > higherThanNum
  } else {
    return eventName.localizedCompare(higherThan) == .orderedDescending
  }
}

func removePrefixIfPresent(key: String, prefix: String) -> String {
  if key.hasPrefix(prefix) {
    return String(key.dropFirst(prefix.count))
  }

  return key
}

func hasHigherTriggeredEvent(
  activityName: String,
  callbackName: String,
  eventName: String,
  afterDate: Double
) -> Bool {
  let prefix = "events_\(activityName)_\(callbackName)_"

  if let actualDict = userDefaults?.dictionaryRepresentation() {
    let foundHigherEvent = actualDict.contains(where: { (key: String, value: Any) in
      if let triggeredAt = value as? Double {
        return
          key
          .starts(
            with: prefix
          )
          && triggeredAt > afterDate
          && isHigherEvent(
            eventName: removePrefixIfPresent(key: key, prefix: prefix),
            higherThan: eventName
          )
      }
      return false
    })

    if foundHigherEvent {
      return true
    }
  }

  return false
}

func isEqual(
  _ selection1: FamilyActivitySelection,
  _ selection2: FamilyActivitySelection
) -> Bool {
  let diff = symmetricDifference(selection1, selection2)
  return diff.categoryTokens.isEmpty && diff.applicationTokens.isEmpty
    && diff.webDomainTokens.isEmpty
}

func shouldExecuteAction(
  skipIfAlreadyTriggeredAfter: Double?,
  skipIfLargerEventRecordedAfter: Double?,
  skipIfAlreadyTriggeredWithinMS: Double?,
  skipIfLargerEventRecordedWithinMS: Double?,
  neverTriggerBefore: Double?,
  skipIfLargerEventRecordedSinceIntervalStarted: Bool?,
  skipIfAlreadyTriggeredBefore: Double?,
  skipIfAlreadyTriggeredBetweenFromDate: Double?,
  skipIfAlreadyTriggeredBetweenToDate: Double?,
  skipIfWhitelistOrBlacklistIsUnchanged: Bool?,
  originalWhitelist: FamilyActivitySelection,
  originalBlocklist: FamilyActivitySelection,
  activityName: String,
  callbackName: String,
  eventName: String?
) -> Bool {
  if let neverTriggerBefore = neverTriggerBefore {
    let now = Date().timeIntervalSince1970 * 1000
    if now < neverTriggerBefore {
      return false
    }
  }

  if let skipIfWhitelistOrBlacklistIsUnchanged = skipIfWhitelistOrBlacklistIsUnchanged {
    if skipIfWhitelistOrBlacklistIsUnchanged {
      let whitelistIsEqual = isEqual(originalWhitelist, getCurrentWhitelist())
      let blocklistIsEqual = isEqual(originalBlocklist, getCurrentBlocklist())
      if whitelistIsEqual && blocklistIsEqual {
        return false
      }
    }
  }

  if let skipIfAlreadyTriggeredAfter = skipIfAlreadyTriggeredAfter {
    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      if lastTriggeredAt > skipIfAlreadyTriggeredAfter {
        logger.log(
          "skipping executing actions for \(callbackName, privacy: .public)\(eventName ?? "", privacy: .public) because the last triggered time is after \(skipIfAlreadyTriggeredAfter, privacy: .public)"
        )
        return false
      }
    }
  }

  if skipIfAlreadyTriggeredBetweenFromDate != nil || skipIfAlreadyTriggeredBetweenToDate != nil {
    let skipIfAlreadyTriggeredBetweenFromDate =
      skipIfAlreadyTriggeredBetweenFromDate ?? Date.distantPast.timeIntervalSince1970 * 1000
    let skipIfAlreadyTriggeredBetweenToDate =
      skipIfAlreadyTriggeredBetweenToDate ?? Date.distantFuture.timeIntervalSince1970 * 1000

    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      if lastTriggeredAt >= skipIfAlreadyTriggeredBetweenFromDate
        && lastTriggeredAt <= skipIfAlreadyTriggeredBetweenToDate {
        logger.log(
          "skipping executing actions for \(callbackName, privacy: .public)\(eventName ?? "", privacy: .public) because the last triggered time is between \(skipIfAlreadyTriggeredBetweenFromDate, privacy: .public) and \(skipIfAlreadyTriggeredBetweenToDate, privacy: .public)"
        )
        return false
      }
    }
  }

  if let skipIfAlreadyTriggeredBefore = skipIfAlreadyTriggeredBefore {
    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      if lastTriggeredAt < skipIfAlreadyTriggeredBefore {
        logger.log(
          "skipping executing actions for \(callbackName, privacy: .public)\(eventName ?? "", privacy: .public) because the last triggered time is after \(skipIfAlreadyTriggeredBefore, privacy: .public)"
        )
        return false
      }
    }
  }

  if let skipIfLargerEventRecordedAfter = skipIfLargerEventRecordedAfter, let eventName = eventName {
    if hasHigherTriggeredEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName,
      afterDate: skipIfLargerEventRecordedAfter
    ) {
      logger.log(
        "skipping executing actions for \(eventName, privacy: .public) because a larger event triggered after \(skipIfLargerEventRecordedAfter, privacy: .public)"
      )
      return false
    }
  }

  if let skipIfAlreadyTriggeredWithinMS = skipIfAlreadyTriggeredWithinMS {
    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      let skipIfAlreadyTriggeredAfter =
        Date().timeIntervalSince1970 * 1000 - skipIfAlreadyTriggeredWithinMS
      if lastTriggeredAt > skipIfAlreadyTriggeredAfter {
        logger.log(
          "skipping executing actions for \(callbackName, privacy: .public)\(eventName ?? "", privacy: .public) because the last triggered time is after \(skipIfAlreadyTriggeredAfter, privacy: .public)"
        )
        return false
      }
    }
  }

  if let skipIfLargerEventRecordedWithinMS = skipIfLargerEventRecordedWithinMS,
    let eventName = eventName {
    let skipIfLargerEventRecordedAfter =
      Date().timeIntervalSince1970 * 1000 - skipIfLargerEventRecordedWithinMS
    if hasHigherTriggeredEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName,
      afterDate: skipIfLargerEventRecordedAfter
    ) {
      logger.log(
        "skipping executing actions for \(eventName, privacy: .public) because a larger event triggered after \(skipIfLargerEventRecordedAfter, privacy: .public)"
      )
      return false
    }
  }

  if let skipIfLargerEventRecordedSinceIntervalStarted =
    skipIfLargerEventRecordedSinceIntervalStarted, let eventName = eventName {
    if skipIfLargerEventRecordedSinceIntervalStarted {
      if let skipIfLargerEventRecordedAfter = getLastTriggeredTimeFromUserDefaults(
        activityName: activityName,
        callbackName: "intervalDidStart"
      ) {
        if hasHigherTriggeredEvent(
          activityName: activityName,
          callbackName: callbackName,
          eventName: eventName,
          afterDate: skipIfLargerEventRecordedAfter
        ) {
          logger.log(
            "skipping executing actions for \(eventName, privacy: .public) because a larger event triggered after \(skipIfLargerEventRecordedAfter, privacy: .public)"
          )
          return false
        }
      }
    }
  }

  return true
}

func getLastTriggeredTimeFromUserDefaults(
  activityName: String, callbackName: String, eventName: String? = nil
) -> Double? {

  let fullEventName = userDefaultKeyForEvent(
    activityName: activityName,
    callbackName: callbackName,
    eventName: eventName
  )

  let val = userDefaults?.object(forKey: fullEventName)

  return val as? Double
}

func getAppGroupDirectory() -> URL? {
  if let appGroup = appGroup {
    let fileManager = FileManager.default
    let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    return container
  }
  return nil
}

@available(iOS 15.0, *)
func startMonitoringAction(
  activityName: String,
  deviceActivityEvents: [[String: Any]],
  intervalStartDelayMs: Int?,
  intervalEndDelayMs: Int?,
  triggeredBy: String
) {
  // Create date components for schedule
  let now = Date()
  let calendar = Calendar.current

  var intervalStart = DateComponents()
  var intervalEnd = DateComponents()

  if let startDelayMs = intervalStartDelayMs {
    let startDate = now.addingTimeInterval(TimeInterval(startDelayMs) / 1000.0)
    intervalStart = calendar.dateComponents([.hour, .minute, .second], from: startDate)
  }

  if let endDelayMs = intervalEndDelayMs {
    let endDate = now.addingTimeInterval(TimeInterval(endDelayMs) / 1000.0)
    intervalEnd = calendar.dateComponents([.hour, .minute, .second], from: endDate)
  } else {
    // Default to 24 hours from start if not specified
    let defaultEndMs = (intervalStartDelayMs ?? 0) + (24 * 60 * 60 * 1000)
    let endDate = now.addingTimeInterval(TimeInterval(defaultEndMs) / 1000.0)
    intervalEnd = calendar.dateComponents([.hour, .minute, .second], from: endDate)
  }

  let schedule = DeviceActivitySchedule(
    intervalStart: intervalStart,
    intervalEnd: intervalEnd,
    repeats: false
  )

  // Create DeviceActivityEvent dictionary
  var eventDict: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

  for eventData in deviceActivityEvents {
    guard let eventName = eventData["eventName"] as? String,
      let threshold = eventData["threshold"] as? [String: Any],
      let familyActivitySelection = eventData["familyActivitySelection"] as? String
    else {
      continue
    }

    let selection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: familyActivitySelection)

    // Convert threshold to DateComponents
    var thresholdComponents = DateComponents()
    if let hour = threshold["hour"] as? Int { thresholdComponents.hour = hour }
    if let minute = threshold["minute"] as? Int { thresholdComponents.minute = minute }
    if let second = threshold["second"] as? Int { thresholdComponents.second = second }

    let includesPastActivity = eventData["includesPastActivity"] as? Bool ?? false

    var event: DeviceActivityEvent
    if #available(iOS 17.4, *) {
      event = DeviceActivityEvent(
        applications: selection.applicationTokens,
        categories: selection.categoryTokens,
        webDomains: selection.webDomainTokens,
        threshold: thresholdComponents,
        includesPastActivity: includesPastActivity
      )
    } else {
      event = DeviceActivityEvent(
        applications: selection.applicationTokens,
        categories: selection.categoryTokens,
        webDomains: selection.webDomainTokens,
        threshold: thresholdComponents
      )
    }

    eventDict[DeviceActivityEvent.Name(eventName)] = event
  }

  let activityName = DeviceActivityName(activityName)

  do {
    try center.startMonitoring(activityName, during: schedule, events: eventDict)
    logger.log(
      "✅ Successfully started monitoring activity: \(activityName.rawValue, privacy: .public) from \(triggeredBy, privacy: .public)"
    )
  } catch {
    logger.log(
      "❌ Failed to start monitoring activity: \(activityName.rawValue, privacy: .public) - \(error.localizedDescription, privacy: .public)"
    )
  }
}

@available(iOS 15.0, *)
func stopMonitoringAction(
  activityNames: [String]?,
  triggeredBy: String
) {
  if let activityNames = activityNames {
    // Stop specific activities
    let deviceActivityNames = activityNames.map { DeviceActivityName($0) }
    center.stopMonitoring(deviceActivityNames)
    logger.log(
      "✅ Successfully stopped monitoring activities: \(activityNames.joined(separator: ", "), privacy: .public) from \(triggeredBy, privacy: .public)"
    )
  } else {
    // Stop all monitoring
    center.stopMonitoring()
    logger.log("✅ Successfully stopped all monitoring from \(triggeredBy, privacy: .public)")
  }
}
