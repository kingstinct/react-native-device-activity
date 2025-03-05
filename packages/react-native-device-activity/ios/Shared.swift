//
//  Utils.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-07.
//

import FamilyControls
import Foundation
import ManagedSettings
import UIKit
import WebKit
import os

let SHIELD_CONFIGURATION_KEY = "shieldConfiguration"
let SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX = "shieldConfigurationForSelection"
let SHIELD_ACTIONS_FOR_SELECTION_PREFIX = "shieldActionsForSelection"
let SHIELD_ACTIONS_KEY = "shieldActions"
let CURRENT_BLOCKED_SELECTION = "currentBlockedSelection"
let CURRENT_UNBLOCKED_SELECTION = "currentUnblockedSelection"
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
    userDefaults?.set(shieldConfiguration, forKey: SHIELD_CONFIGURATION_KEY)
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

@available(iOS 15.0, *)
func setFamilyActivitySelectionById(id: String, activitySelection: FamilyActivitySelection) {
  if var familyActivitySelectionIds = userDefaults?.dictionary(
    forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY) {
    familyActivitySelectionIds[id] = serializeFamilyActivitySelection(
      selection: activitySelection
    )

    userDefaults?
      .set(familyActivitySelectionIds, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  } else {
    let dict = [
      id: serializeFamilyActivitySelection(selection: activitySelection)
    ]
    userDefaults?.set(dict, forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  }
}

@available(iOS 15.0, *)
func getActivitySelectionPrefixedConfigFromUserDefaults(
  keyPrefix: String,
  defaultKey: String,
  applicationToken: ApplicationToken? = nil,
  webDomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil
) -> [String: Any]? {
  let familyActivitySelectionIds = getFamilyActivitySelectionIds()

  let activitySelection = familyActivitySelectionIds.first(
    where: { (activitySelectionPair) in
      guard
        (userDefaults?.dictionary(
          forKey: keyPrefix + "_" + activitySelectionPair.id
        )) != nil
      else {
        return false
      }

      if let applicationToken = applicationToken {
        if activitySelectionPair.selection.applicationTokens
          .contains(applicationToken) {
          return true
        }
      }

      if let webDomainToken = webDomainToken {
        if activitySelectionPair.selection.webDomainTokens.contains(webDomainToken) {
          return true
        }
      }

      if let categoryToken = categoryToken {
        if activitySelectionPair.selection.categoryTokens.contains(categoryToken) {
          return true
        }
      }

      return false
    })

  if let activitySelection = activitySelection {
    return userDefaults?.dictionary(forKey: keyPrefix + "_" + activitySelection.id)
  }

  return userDefaults?.dictionary(forKey: defaultKey)
}

@available(iOS 15.0, *)
func getPossibleFamilyActivitySelectionId(
  applicationToken: ApplicationToken? = nil,
  webDomainToken: WebDomainToken? = nil,
  categoryToken: ActivityCategoryToken? = nil
) -> String? {
  let familyActivitySelectionIds = getFamilyActivitySelectionIds()

  let foundIt = familyActivitySelectionIds.first(where: { (activitySelection) in
    if let applicationToken = applicationToken {
      if activitySelection.selection.applicationTokens.contains(applicationToken) {
        return true
      }
    }

    if let webDomainToken = webDomainToken {
      if activitySelection.selection.webDomainTokens.contains(webDomainToken) {
        return true
      }
    }

    if let categoryToken = categoryToken {
      if activitySelection.selection.categoryTokens.contains(categoryToken) {
        return true
      }
    }

    return false
  })

  return foundIt?.id
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
    logger.log("decode error \(error.localizedDescription)")
  }

  return activitySelection
}

@available(iOS 15.0, *)
func serializeFamilyActivitySelection(selection: FamilyActivitySelection) -> String? {
  let encoder = JSONEncoder()
  do {
    let json = try encoder.encode(selection)
    let jsonString = json.base64EncodedString()

    let noneSeleted =
      selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty
      && selection.webDomainTokens.isEmpty

    let familyActivitySelectionString = noneSeleted ? nil : jsonString

    return familyActivitySelectionString
  } catch {
    return nil
  }
}

@available(iOS 15.0, *)
func unblockAllApps(triggeredBy: String) {
  userDefaults?
    .removeObject(forKey: CURRENT_BLOCKED_SELECTION)

  userDefaults?
    .removeObject(forKey: IS_BLOCKING_ALL)

  userDefaults?.removeObject(forKey: CURRENT_UNBLOCKED_SELECTION)

  store.shield.applicationCategories = nil
  store.shield.webDomainCategories = nil

  store.shield.applications = .none
  store.shield.webDomains = .none

  userDefaults?.set(
    [
      "triggeredBy": triggeredBy,
      "unblockedAt": Date.now.ISO8601Format()
    ], forKey: "lastUnblock")
}

@available(iOS 15.0, *)
func blockAllApps(triggeredBy: String) {
  userDefaults?
    .removeObject(forKey: CURRENT_UNBLOCKED_SELECTION)
  userDefaults?
    .removeObject(forKey: CURRENT_BLOCKED_SELECTION)

  userDefaults?.set(true, forKey: IS_BLOCKING_ALL)

  store.shield.applicationCategories = .all(except: Set())
  store.shield.webDomainCategories = .all(except: Set())

  userDefaults?.set(
    [
      "triggeredBy": triggeredBy,
      "blockedAt": Date.now.ISO8601Format()
    ], forKey: "lastBlock")
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

  var selection = FamilyActivitySelection()

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

  var selection = FamilyActivitySelection()

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

  var selection = FamilyActivitySelection()

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

  var selection = FamilyActivitySelection()

  selection.applicationTokens = applicationTokens
  selection.webDomainTokens = domainTokens
  selection.categoryTokens = categoryTokens

  return selection
}

@available(iOS 15.0, *)
func blockSelectedApps(
  blockSelection: FamilyActivitySelection,
  triggeredBy: String,
  blockedFamilyActivitySelectionId: String?
) {
  // doesn't work together with blockAll, and doesn't really make sense together
  userDefaults?
    .removeObject(forKey: IS_BLOCKING_ALL)

  let currentBlockedSelection = userDefaults?
    .string(forKey: CURRENT_BLOCKED_SELECTION)

  let currentUnblockedSelectionSerialized = userDefaults?
    .string(forKey: CURRENT_UNBLOCKED_SELECTION)

  let previousSelection =
    currentBlockedSelection != nil
    ? deserializeFamilyActivitySelection(familyActivitySelectionStr: currentBlockedSelection!)
    : nil

  let currentUnblockedSelection =
    currentUnblockedSelectionSerialized != nil
    ? difference(
      deserializeFamilyActivitySelection(
        familyActivitySelectionStr: currentUnblockedSelectionSerialized!
      ), blockSelection) : FamilyActivitySelection()

  let combinedSelection =
    previousSelection != nil
    ? union(blockSelection, previousSelection!)
    : blockSelection

  store.shield.applications = combinedSelection.applicationTokens

  store.shield.webDomains = combinedSelection.webDomainTokens

  store.shield.applicationCategories = .specific(
    combinedSelection.categoryTokens,
    except: currentUnblockedSelection.applicationTokens
  )

  store.shield.webDomainCategories = .specific(
    combinedSelection.categoryTokens,
    except: currentUnblockedSelection.webDomainTokens
  )

  userDefaults?
    .set(
      serializeFamilyActivitySelection(selection: currentUnblockedSelection),
      forKey: CURRENT_UNBLOCKED_SELECTION
    )

  userDefaults?
    .set(
      serializeFamilyActivitySelection(selection: combinedSelection),
      forKey: CURRENT_BLOCKED_SELECTION
    )

  userDefaults?.set(
    [
      "triggeredBy": triggeredBy,
      "blockedAt": Date.now.ISO8601Format(),
      "blockedFamilyActivitySelectionId": blockedFamilyActivitySelectionId as Any,
      "blockedAppCount": combinedSelection.applicationTokens.count,
      "blockedWebDomainCount": combinedSelection.webDomainTokens.count,
      "blockedCategoryCount": combinedSelection.categoryTokens.count
    ], forKey: "lastBlock")
}

@available(iOS 15.0, *)
func unblockSelectedApps(
  unblockSelection: FamilyActivitySelection,
  triggeredBy: String
) {
  let isBlockingAll = userDefaults?.bool(forKey: IS_BLOCKING_ALL) ?? false

  let currentUnblockedSelectionSerialized = userDefaults?
    .string(forKey: CURRENT_UNBLOCKED_SELECTION)

  let currentUnblockedSelection =
    currentUnblockedSelectionSerialized != nil
    ? deserializeFamilyActivitySelection(
      familyActivitySelectionStr: currentUnblockedSelectionSerialized!
    ) : FamilyActivitySelection()

  if isBlockingAll {
    // note: for whitelisting to work with categories, it seems the FamilyActivitySelection needs to be initialized with includeEntireCategory: true - which is not currently exposed by this library (it is probably challenging to make it stable since the selection could get so big)
    store.shield.applicationCategories = .all(
      except: currentUnblockedSelection.applicationTokens
    )
    store.shield.webDomainCategories = .all(
      except: currentUnblockedSelection.webDomainTokens
    )

    return
  }

  let currentBlockedSelectionStr = userDefaults?
    .string(forKey: CURRENT_BLOCKED_SELECTION)

  let currentBlockedSelection =
    currentBlockedSelectionStr != nil
    ? deserializeFamilyActivitySelection(familyActivitySelectionStr: currentBlockedSelectionStr!)
    : FamilyActivitySelection()

  let combinedUnblockedSelection = union(currentUnblockedSelection, unblockSelection)

  store.shield.applications = currentBlockedSelection.applicationTokens

  store.shield.webDomains = currentBlockedSelection.webDomainTokens

  store.shield.applicationCategories = .specific(
    currentBlockedSelection.categoryTokens,
    except: combinedUnblockedSelection.applicationTokens
  )
  store.shield.webDomainCategories = .specific(
    currentBlockedSelection.categoryTokens,
    except: combinedUnblockedSelection.webDomainTokens
  )

  userDefaults?
    .set(
      serializeFamilyActivitySelection(selection: combinedUnblockedSelection),
      forKey: CURRENT_UNBLOCKED_SELECTION
    )

  userDefaults?.set(
    [
      "triggeredBy": triggeredBy,
      "unblockedAt": Date.now.ISO8601Format(),
      "blockedAppCount": currentBlockedSelection.applicationTokens.count,
      "blockedWebDomainCount": currentBlockedSelection.webDomainTokens.count,
      "blockedCategoryCount": currentBlockedSelection.categoryTokens.count,
      "unblockedAppCount": currentUnblockedSelection.applicationTokens.count,
      "unblockedWebDomainCount": currentUnblockedSelection.webDomainTokens.count,
      "unblockedCategoryCount": currentUnblockedSelection.categoryTokens.count
    ], forKey: "lastUnblock")
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

  if let skipIfAlreadyTriggeredAfter = skipIfAlreadyTriggeredAfter {
    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      if lastTriggeredAt > skipIfAlreadyTriggeredAfter {
        logger.log(
          "skipping executing actions for \(callbackName)\(eventName ?? "") because the last triggered time is after \(skipIfAlreadyTriggeredAfter)"
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
          "skipping executing actions for \(callbackName)\(eventName ?? "") because the last triggered time is between \(skipIfAlreadyTriggeredBetweenFromDate) and \(skipIfAlreadyTriggeredBetweenToDate)"
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
          "skipping executing actions for \(callbackName)\(eventName ?? "") because the last triggered time is after \(skipIfAlreadyTriggeredBefore)"
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
        "skipping executing actions for \(eventName) because a larger event triggered after \(skipIfLargerEventRecordedAfter)"
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
          "skipping executing actions for \(callbackName)\(eventName ?? "") because the last triggered time is after \(skipIfAlreadyTriggeredAfter)"
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
        "skipping executing actions for \(eventName) because a larger event triggered after \(skipIfLargerEventRecordedAfter)"
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
            "skipping executing actions for \(eventName) because a larger event triggered after \(skipIfLargerEventRecordedAfter)"
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
