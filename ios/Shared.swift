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

let appGroup =
  Bundle.main.object(forInfoDictionaryKey: "REACT_NATIVE_DEVICE_ACTIVITY_APP_GROUP") as? String
var userDefaults = UserDefaults(suiteName: appGroup)

@available(iOS 14.0, *)
let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

var task: URLSessionDataTask?

func updateShield(shieldId: String?) {
  let shieldId = shieldId ?? "default"

  if let shieldConfiguration = userDefaults?.dictionary(
    forKey: "shieldConfiguration_\(shieldId)") {
    // update default shield
    userDefaults?.set(shieldConfiguration, forKey: "shieldConfiguration")
  }

  if let shieldActions = userDefaults?.dictionary(
    forKey: "shieldActions_\(shieldId)") {
    userDefaults?.set(shieldActions, forKey: "shieldActions")
  }
}

func sleep(ms: Int) {
  let delay = DispatchTimeInterval.milliseconds(ms)
  let group = DispatchGroup()
  group.enter()
  _ = group.wait(timeout: .now() + delay)
}

@available(iOS 15.0, *)
func executeAction(action: [String: Any], placeholders: [String: String?]) {
  let type = action["type"] as? String

  if let sleepBefore = action["sleepBefore"] as? Int {
    sleep(ms: sleepBefore)
  }

  if type == "blockSelection" {
    if let familyActivitySelectionId = action["familyActivitySelectionId"] as? String {
      if let activitySelection = getFamilyActivitySelectionById(id: familyActivitySelectionId) {
        updateShield(shieldId: action["shieldId"] as? String)

        sleep(ms: 50)

        blockSelectedApps(
          blockSelection: activitySelection,
          unblockedSelection: nil
        )
      } else {
        logger.log("No familyActivitySelection found with ID: \(familyActivitySelectionId)")
      }
    }
  } else if type == "resetUnblockedSelection" {
    userDefaults?.removeObject(forKey: "unblockedSelection")
  } else if type == "unblockAllApps" {
    unblockAllApps()
  } else if type == "openApp" {
    // todo: replace with general string
    openUrl(urlString: "device-activity://")

    sleep(ms: 1000)
  } else if type == "blockAllApps" {
    updateShield(shieldId: action["shieldId"] as? String)

    // sometimes the shield doesn't pick up the shield config change above, trying a sleep to get around it
    sleep(ms: 50)

    blockAllApps()
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
  }

  if let sleepAfter = action["sleepAfter"] as? Int {
    sleep(ms: sleepAfter)
  }
}

@available(iOS 15.0, *)
func isShieldActive() -> Bool {
  let areAnyApplicationsShielded =
    store.shield.applications != nil && store.shield.applications!.count > 0
  let areAnyWebDomainsShielded =
    store.shield.webDomains != nil && store.shield.webDomains!.count > 0
  let areAnyApplicationCategoriesShielded =
    store.shield.applicationCategories != nil
    && store.shield.applicationCategories
      != ShieldSettings.ActivityCategoryPolicy<Application>.none
  let areAnyWebDomainCategoriesShielded =
    store.shield.webDomainCategories != nil
    && store.shield.webDomainCategories != ShieldSettings.ActivityCategoryPolicy<WebDomain>.none

  return areAnyApplicationsShielded || areAnyWebDomainsShielded
    || areAnyApplicationCategoriesShielded || areAnyWebDomainCategoriesShielded
}

func openUrl(urlString: String) {
  guard let url = URL(string: urlString) else {
    return  // be safe
  }

  let context = NSExtensionContext()
  context.open(url) { _ in

  }

  /* let webView = WKWebView()
  webView.load(URLRequest(url: url))
*/
  /*let application =
    UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as! UIApplication*/

  /*if #available(iOS 10.0, *) {
    application.open(url, options: [:], completionHandler: nil)
  } else {
    application.openURL(url)
  }*/
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
  return TextToReplaceWithOptionalSpecialTreatment(textToReplace: stringToReplace)
}

/* handles replacements in an entire dictionary as well as two special cases:
 // - userDefaults:any-key-in-user-defaults -> will replace an entire value with the value in userDefaults, could be used as
 "headers": {
 "authorization": "{userDefaults:AUTH_HEADER}"
 }
 // asNumber:eventName -> will instead of a String parse it as a number:
 "data": {
 "minutes": "{asNumber:eventName}"
 }
 */
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
let store = ManagedSettingsStore()

@available(iOS 15.0, *)
func getFamilyActivitySelectionIds() -> [FamilyActivitySelectionWithId?] {
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
  if let familyActivitySelectionIds = userDefaults?.dictionary(forKey: "familyActivitySelectionIds") {
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
func getPossibleFamilyActivitySelectionId(
  applicationToken: ApplicationToken?,
  webDomainToken: WebDomainToken?,
  categoryToken: ActivityCategoryToken?
) -> String? {
  let familyActivitySelectionIds = getFamilyActivitySelectionIds()

  let foundIt = familyActivitySelectionIds.first(where: { (mapping) in
    if let mapping = mapping {
      if let applicationToken = applicationToken {
        if mapping.selection.applicationTokens.contains(applicationToken) {
          return true
        }
      }

      if let webDomainToken = webDomainToken {
        if mapping.selection.webDomainTokens.contains(webDomainToken) {
          return true
        }
      }

      if let categoryToken = categoryToken {
        if mapping.selection.categoryTokens.contains(categoryToken) {
          return true
        }
      }
    }

    return false
  })

  return foundIt??.id
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
func unblockAllApps() {
  store.shield.applicationCategories = nil
  store.shield.webDomainCategories = nil

  store.shield.applications = .none
  store.shield.webDomains = .none
}

@available(iOS 15.0, *)
func blockAllApps() {
  store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
  store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
}

@available(iOS 15.0, *)
func blockSelectedApps(
  blockSelection: FamilyActivitySelection?,
  unblockedSelection: FamilyActivitySelection?
) {
  store.shield.applications = blockSelection?.applicationTokens.filter({ token in
    if let match = unblockedSelection?.applicationTokens.first(where: { $0 == token }) {
      return match == nil
    }
    return true
  })

  store.shield.webDomains = blockSelection?.webDomainTokens.filter({ token in
    if let match = unblockedSelection?.webDomainTokens.first(where: { $0 == token }) {
      return match == nil
    }
    return true
  })

  let applications = unblockedSelection?.applicationTokens ?? Set()
  let webDomains = unblockedSelection?.webDomainTokens ?? Set()

  if let blockSelection = blockSelection {
    store.shield.applicationCategories = .specific(
      blockSelection.categoryTokens,
      except: applications
    )
    store.shield.webDomainCategories = .specific(
      blockSelection.categoryTokens,
      except: webDomains
    )
  } else {
    store.shield.applicationCategories = .all(
      except: applications
    )
    store.shield.webDomainCategories = .all(
      except: webDomains
    )
  }
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

func replace(key: String, prefix: String) -> String {
  if key.hasPrefix(prefix) {
    return String(key.dropFirst(prefix.count))
  }

  return key
}

func hasHigherTriggeredEvent(
  activityName: String,
  callbackName: String,
  eventName: String?,
  afterDate: Double
) -> Bool {
  let prefix = "events_\(activityName)_"

  if let actualDict = userDefaults?.dictionaryRepresentation() {
    let higherEvent = actualDict.first(where: { (key: String, value: Any) in
      if let triggeredAt = value as? Double {
        return
          key
          .starts(
            with: prefix
          )
          && triggeredAt > afterDate
          && (eventName != nil
            ? isHigherEvent(
              eventName: replace(key: key, prefix: prefix),
              higherThan: eventName!
            ) : true)
      }
      return false

    })

    if higherEvent != nil {
      return true
    }
  }

  return false
}

@available(iOS 15.0, *)
func shouldExecuteAction(
  skipIfAlreadyTriggeredAfter: Double?,
  skipIfLargerEventRecordedAfter: Double?,
  skipIfAlreadyTriggeredWithinMS: Double?,
  skipIfLargerEventRecordedWithinMS: Double?,
  activityName: String,
  callbackName: String,
  eventName: String?
) -> Bool {
  if let skipIfAlreadyTriggeredAfter = skipIfAlreadyTriggeredAfter {
    if let lastTriggeredAt = getLastTriggeredTimeFromUserDefaults(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    ) {
      if lastTriggeredAt > skipIfAlreadyTriggeredAfter {
        return false
      }
    }
  }

  if let skipIfLargerEventRecordedAfter = skipIfLargerEventRecordedAfter {
    if hasHigherTriggeredEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName,
      afterDate: skipIfLargerEventRecordedAfter
    ) {
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
      Date.now.addingTimeInterval(
        -skipIfAlreadyTriggeredWithinMS / 1000
      ).timeIntervalSince1970 * 1000
      if lastTriggeredAt > skipIfAlreadyTriggeredAfter {
        return false
      }
    }
  }

  if let skipIfLargerEventRecordedWithinMS = skipIfLargerEventRecordedWithinMS {
    if hasHigherTriggeredEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName,
      afterDate: Date.now
        .addingTimeInterval(-skipIfLargerEventRecordedWithinMS).timeIntervalSince1970 * 1000
    ) {
      return false
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

func traverseDirectory(at path: String) {
  do {
    let files = try FileManager.default.contentsOfDirectory(atPath: path)

    for file in files {
      let fullPath = path + "/" + file
      var isDirectory: ObjCBool = false

      if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
          print("\(fullPath) is a directory")
          // Recursively traverse subdirectory
          traverseDirectory(at: fullPath)
        } else if fullPath.hasSuffix("png") {
          print("\(fullPath) is a file")
        }
      } else {
        print("\(fullPath) does not exist")
      }
    }
  } catch {
    print("Error traversing directory at path \(path): \(error.localizedDescription)")
  }
}

func getAppGroupDirectory() -> URL? {
  if let appGroup = appGroup {
    let fileManager = FileManager.default
    let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    return container
  }
  return nil
}

func loadImageFromAppGroupDirectory(relativeFilePath: String) -> UIImage? {
  let appGroupDirectory = getAppGroupDirectory()

  let fileURL = appGroupDirectory!.appendingPathComponent(relativeFilePath)

  // Load the image data
  guard let imageData = try? Data(contentsOf: fileURL) else {
    print("Error: Could not load data from \(fileURL.path)")
    return nil
  }

  // Create and return the UIImage
  return UIImage(data: imageData)
}

func loadImageFromBundle(assetName: String) -> UIImage? {
  // Get the main bundle
  let bundle = Bundle.main
  // Bundle.main.
  guard let fURL = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: ".") else {
    return nil
  }

  logger.info("Found \(fURL.count) png files in bundle")

  traverseDirectory(at: Bundle.main.bundlePath)

  for url in fURL {
    logger.info("url: \(url.lastPathComponent)")
  }

  // Construct the file URL for the asset
  guard let filePath = bundle.path(forResource: assetName, ofType: "png") else {
    print("Error: Asset not found in bundle: \(assetName).png")
    return nil
  }

  // Load image data
  guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
    print("Error: Could not load data from \(filePath)")
    return nil
  }

  // Create UIImage from data
  return UIImage(data: imageData)
}

func loadImageFromFileSystem(filePath: String) -> UIImage? {
  let fileURL = URL(fileURLWithPath: filePath)

  // Load data from the file URL
  guard let imageData = try? Data(contentsOf: fileURL) else {
    print("Error: Could not load data from \(filePath)")
    return nil
  }

  // Create UIImage from the data
  return UIImage(data: imageData)
}

func loadImageFromRemoteURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
  guard let url = URL(string: urlString) else {
    print("Error: Invalid URL string")
    completion(nil)
    return
  }

  let task = URLSession.shared.dataTask(with: url) { data, _, error in
    // Handle errors
    if let error = error {
      print("Error fetching image from URL: \(error)")
      completion(nil)
      return
    }

    // Validate data
    guard let imageData = data, let image = UIImage(data: imageData) else {
      print("Error: Invalid image data from \(urlString)")
      completion(nil)
      return
    }

    completion(image)
  }

  task.resume()
}

func loadImageFromRemoteURLSynchronously(urlString: String) -> UIImage? {
  guard let url = URL(string: urlString) else {
    logger.info("Error: Invalid URL string")
    return nil
  }

  var image: UIImage?
  let semaphore = DispatchSemaphore(value: 0)

  logger.info("Getting image")

  let task = URLSession.shared.dataTask(with: url) { data, _, error in
    // Handle errors
    if let error = error {
      logger.info("Error fetching image: \(error)")
    }

    // Validate data
    if let imageData = data {
      logger.info("Got image")
      image = UIImage(data: imageData)
    }

    // Signal the semaphore to release the lock
    semaphore.signal()
  }

  task.resume()

  // Wait for the task to complete
  semaphore.wait()

  return image
}
