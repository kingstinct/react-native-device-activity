import Combine
import DeviceActivity
import ExpoModulesCore
import FamilyControls
import Foundation
import ManagedSettings
import ManagedSettingsUI
import os

struct DateComponentsFromJS: ExpoModulesCore.Record {
  @Field
  var era: Int?
  @Field
  var year: Int?
  @Field
  var month: Int?
  @Field
  var day: Int?
  @Field
  var hour: Int?
  @Field
  var minute: Int?
  @Field
  var second: Int?
  @Field
  var nanosecond: Int?
  @Field
  var weekday: Int?
  @Field
  var weekdayOrdinal: Int?
  @Field
  var quarter: Int?
  @Field
  var weekOfMonth: Int?
  @Field
  var weekOfYear: Int?
  @Field
  var yearForWeekOfYear: Int?
  @Field
  var timeZoneOffsetInSeconds: Int?
  @Field
  var timeZoneIdentifier: String?
}

struct ScheduleFromJS: ExpoModulesCore.Record {
  @Field
  var intervalStart: DateComponentsFromJS
  @Field
  var intervalEnd: DateComponentsFromJS

  @Field
  var repeats: Bool?

  @Field
  var warningTime: DateComponentsFromJS?
}

@available(iOS 15.0, *)
struct ActivitySelectionWithMetadata: ExpoModulesCore.Record {
  init() {

  }

  init(
    activitySelection: FamilyActivitySelection,
    stripToken: Bool? = false
  ) {
    let stripToken = stripToken ?? false
    if !stripToken {
      self.familyActivitySelection = serializeFamilyActivitySelection(
        selection: activitySelection
      )
    }
    self.applicationCount = activitySelection.applicationTokens.count
    self.categoryCount = activitySelection.categoryTokens.count
    self.webdomainCount = activitySelection.webDomainTokens.count

    if #available(iOS 15.2, *) {
      self.includeEntireCategory = activitySelection.includeEntireCategory
    } else {
      self.includeEntireCategory = false
    }
  }

  @Field
  var familyActivitySelection: String?
  @Field
  var applicationCount: Int
  @Field
  var categoryCount: Int
  @Field
  var webdomainCount: Int
  @Field
  var includeEntireCategory: Bool
}

@available(iOS 15.0, *)
struct ActivitySelectionMetadata: ExpoModulesCore.Record {
  init() {

  }

  init(
    activitySelection: FamilyActivitySelection
  ) {
    self.applicationCount = activitySelection.applicationTokens.count
    self.categoryCount = activitySelection.categoryTokens.count
    self.webdomainCount = activitySelection.webDomainTokens.count
    if #available(iOS 15.2, *) {
      self.includeEntireCategory = activitySelection.includeEntireCategory
    } else {
      self.includeEntireCategory = false
    }
  }
  @Field
  var applicationCount: Int
  @Field
  var categoryCount: Int
  @Field
  var webdomainCount: Int
  @Field
  var includeEntireCategory: Bool
}

struct DeviceActivityEventFromJS: ExpoModulesCore.Record {
  @Field
  var familyActivitySelectionIndex: Int
  @Field
  var threshold: DateComponentsFromJS
  @Field
  var eventName: String
  @Field
  var includesPastActivity: Bool?
}

func convertToSwiftDateComponents(from dateComponentsFromJS: DateComponentsFromJS) -> DateComponents {
  var swiftDateComponents = DateComponents()

  if let era = dateComponentsFromJS.era {
    swiftDateComponents.era = era
  }
  if let year = dateComponentsFromJS.year {
    swiftDateComponents.year = year
  }
  if let month = dateComponentsFromJS.month {
    swiftDateComponents.month = month
  }
  if let day = dateComponentsFromJS.day {
    swiftDateComponents.day = day
  }
  if let hour = dateComponentsFromJS.hour {
    swiftDateComponents.hour = hour
  }
  if let minute = dateComponentsFromJS.minute {
    swiftDateComponents.minute = minute
  }
  if let second = dateComponentsFromJS.second {
    swiftDateComponents.second = second
  }
  if let nanosecond = dateComponentsFromJS.nanosecond {
    swiftDateComponents.nanosecond = nanosecond
  }
  if let weekday = dateComponentsFromJS.weekday {
    swiftDateComponents.weekday = weekday
  }
  if let weekdayOrdinal = dateComponentsFromJS.weekdayOrdinal {
    swiftDateComponents.weekdayOrdinal = weekdayOrdinal
  }
  if let quarter = dateComponentsFromJS.quarter {
    swiftDateComponents.quarter = quarter
  }
  if let weekOfMonth = dateComponentsFromJS.weekOfMonth {
    swiftDateComponents.weekOfMonth = weekOfMonth
  }
  if let weekOfYear = dateComponentsFromJS.weekOfYear {
    swiftDateComponents.weekOfYear = weekOfYear
  }
  if let yearForWeekOfYear = dateComponentsFromJS.yearForWeekOfYear {
    swiftDateComponents.yearForWeekOfYear = yearForWeekOfYear
  }
  if let timeZoneIdentifier = dateComponentsFromJS.timeZoneIdentifier {
    swiftDateComponents.timeZone = TimeZone(identifier: timeZoneIdentifier)
    if swiftDateComponents.timeZone == nil {
      swiftDateComponents.timeZone = TimeZone(abbreviation: timeZoneIdentifier)
    }
  }
  if let timeZoneOffsetInSeconds = dateComponentsFromJS.timeZoneOffsetInSeconds {
    swiftDateComponents.timeZone = TimeZone(secondsFromGMT: timeZoneOffsetInSeconds)
  }

  return swiftDateComponents
}

class NativeEventObserver {
  let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
  let observer: UnsafeRawPointer

  func registerListener(name: String) {
    let notificationName = name as CFString
    CFNotificationCenterAddObserver(
      notificationCenter,
      observer,
      {
        (
          _: CFNotificationCenter?,
          observer: UnsafeMutableRawPointer?,
          name: CFNotificationName?,
          _: UnsafeRawPointer?,
          _: CFDictionary?
        ) in
        if let observer = observer, let name = name {
          let mySelf = Unmanaged<BaseModule>.fromOpaque(observer).takeUnretainedValue()

          mySelf.sendEvent(
            "onDeviceActivityMonitorEvent" as String,
            [
              "callbackName": name.rawValue
            ])
        }
      },
      notificationName,
      nil,
      CFNotificationSuspensionBehavior.deliverImmediately)
  }

  init(module: BaseModule) {
    observer = UnsafeRawPointer(Unmanaged.passUnretained(module).toOpaque())
    registerListener(name: "intervalDidStart")
    registerListener(name: "intervalDidEnd")
    registerListener(name: "eventDidReachThreshold")
    registerListener(name: "intervalWillStartWarning")
    registerListener(name: "intervalWillEndWarning")
    registerListener(name: "eventWillReachThresholdWarning")
  }

  func unregister() {
    CFNotificationCenterRemoveEveryObserver(notificationCenter, observer)
  }
}

@available(iOS 15.0, *)
func tokenSetsAreEqual<T>(
  tokenSetOne: Set<Token<T>>?,
  tokenSetTwo: Set<Token<T>>
) -> Bool {
  if tokenSetOne == tokenSetTwo {
    return true
  }

  if let tokenSetOne = tokenSetOne {
    if tokenSetOne.count == tokenSetTwo.count {
      if tokenSetOne.count == 0 {
        return true
      }
      return tokenSetOne.allSatisfy { token in
        tokenSetTwo.contains(token)
      }
    }
  } else {
    return tokenSetTwo.isEmpty
  }

  return false
}

@available(iOS 15.0, *)
public class ReactNativeDeviceActivityModule: Module {

  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ReactNativeDeviceActivity')` in JavaScript.
    Name("ReactNativeDeviceActivity")

    // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
    Constants([
      "PI": Double.pi
    ])
    let fileManager = FileManager.default

    var watchActivitiesHandle: Cancellable?
    var onDeviceActivityDetectedHandle: Cancellable?

    Function("getAppGroupFileDirectory") {

      let container = getAppGroupDirectory()
      // try fileManager.createDirectory(at: container!.appendingPathComponent("Documents"), withIntermediateDirectories: false)
      return container?.absoluteString
    }

    Function("moveFile") { (fromUrl: String, toUrl: String, overwrite: Bool?) in
      let from = URL(string: fromUrl)!
      let to = URL(string: toUrl)!

      if overwrite == true {
        do {
          try fileManager.removeItem(at: to)
        } catch {
          logger.info("Error removing file: \(error)")
        }
      }
      try fileManager.moveItem(at: from, to: to)

      return to.absoluteString
    }

    Function("copyFile") { (fromUrl: String, toUrl: String, overwrite: Bool?) in
      let from = URL(string: fromUrl)!
      let to = URL(string: toUrl)!

      if overwrite == true {
        do {
          try fileManager.removeItem(at: to)
        } catch {
          logger.info("Error removing file: \(error)")
        }
      }
      try fileManager.copyItem(at: from, to: to)

      return to.absoluteString
    }

    var observer: NativeEventObserver?

    OnStartObserving {
      observer = NativeEventObserver(module: self)
      onDeviceActivityDetectedHandle = AuthorizationCenter.shared.$authorizationStatus.sink {
        status in
        self.sendEvent(
          "onAuthorizationStatusChange" as String,
          [
            "authorizationStatus": status.rawValue
          ])
      }

      watchActivitiesHandle = center.activities.publisher.sink { activity in
        self.sendEvent(
          "onDeviceActivityDetected" as String,
          [
            "activityName": activity.rawValue
          ])
      }
    }

    OnStopObserving {
      observer?.unregister()
      observer = nil
      watchActivitiesHandle?.cancel()
      onDeviceActivityDetectedHandle?.cancel()
    }

    Function("getEvents") { (activityName: String?) -> [AnyHashable: Any] in
      let dict = userDefaults?.dictionaryRepresentation()

      guard let actualDict = dict else {
        return [:]  // Return an empty dictionary instead of an empty array
      }

      let filteredDict = actualDict.filter({ (key: String, _: Any) in
        return key.starts(with: activityName == nil ? "events_" : "events_\(activityName!)")
      }).reduce(into: [:]) { (result, element) in
        let (key, value) = element
        result[key] = value as? NSNumber  // Add key-value pair to the result dictionary
      }

      return filteredDict
    }

    Function("userDefaultsSet") { (params: [String: Any]) in
      guard let key = params["key"] as? String,
        let value = params["value"]
      else {
        return
      }
      userDefaults?.set(value, forKey: key)
    }

    Function("userDefaultsGet") { (forKey: String) -> Any? in
      return userDefaults?.object(forKey: forKey)
    }

    Function("userDefaultsRemove") { (forKey: String) -> Any? in
      return userDefaults?.removeObject(forKey: forKey)
    }

    Function("userDefaultsClear") { () in
      let dictionary = userDefaults?.dictionaryRepresentation()
      dictionary?.keys.forEach { key in
        userDefaults?.removeObject(forKey: key)
      }
    }

    Function("userDefaultsClearWithPrefix") { (prefix: String) in
      let dictionary = userDefaults?.dictionaryRepresentation()
      dictionary?.keys.forEach { key in
        if key.starts(with: prefix) {
          userDefaults?.removeObject(forKey: key)

        }
      }
    }

    Function("userDefaultsAll") { () -> Any? in
      if let userDefaults = userDefaults {
        return userDefaults.dictionaryRepresentation()
      }
      return nil
    }

    Function("authorizationStatus") {
      let currentStatus = AuthorizationCenter.shared.authorizationStatus

      return currentStatus.rawValue
    }

    Function("refreshManagedSettingsStore") {
      refreshManagedSettingsStore()
    }

    Function("clearAllManagedSettingsStoreSettings") {
      if #available(iOS 16, *) {
        clearAllManagedSettingsStoreSettings()
      }
    }

    Function("unblockSelection") {
      (familyActivitySelection: [String: Any], triggeredBy: String?) in
      let triggeredBy = triggeredBy ?? "called manually"

      let activitySelection = parseActivitySelectionInput(
        input: familyActivitySelection
      )

      unblockSelection(removeSelection: activitySelection, triggeredBy: triggeredBy)

      let blockingAllModeEnabled = isBlockingAllModeEnabled()

      if blockingAllModeEnabled {
        throw TryingToBlockSelectionWhenBlockModeIsEnabledError()
      }
    }

    AsyncFunction("startMonitoring") {
      (
        activityName: String, schedule: ScheduleFromJS, events: [DeviceActivityEventFromJS],
        familyActivitySelections: [String]
      ) in
      let schedule = DeviceActivitySchedule(
        intervalStart: convertToSwiftDateComponents(from: schedule.intervalStart),
        intervalEnd: convertToSwiftDateComponents(from: schedule.intervalEnd),
        repeats: schedule.repeats ?? false,
        warningTime: schedule.warningTime != nil
          ? convertToSwiftDateComponents(from: schedule.warningTime!)
          : nil
      )

      let decodedFamilyActivitySelections = familyActivitySelections.map {
        familyActivitySelection in
        let decoder = JSONDecoder()
        let data = Data(base64Encoded: familyActivitySelection)
        do {
          let activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
          return activitySelection
        } catch {
          return FamilyActivitySelection()
        }
      }

      let dictionary = [DeviceActivityEvent.Name: DeviceActivityEvent](
        uniqueKeysWithValues: events.map { (eventRaw: DeviceActivityEventFromJS) in
          let familyActivitySelection = decodedFamilyActivitySelections[
            eventRaw.familyActivitySelectionIndex]

          let threshold = convertToSwiftDateComponents(from: eventRaw.threshold)
          var event: DeviceActivityEvent

          if #available(iOS 17.4, *) {
            event = DeviceActivityEvent(
              applications: familyActivitySelection.applicationTokens,
              categories: familyActivitySelection.categoryTokens,
              webDomains: familyActivitySelection.webDomainTokens,
              threshold: threshold,
              includesPastActivity: eventRaw.includesPastActivity ?? false
            )
          } else {
            event = DeviceActivityEvent(
              applications: familyActivitySelection.applicationTokens,
              categories: familyActivitySelection.categoryTokens,
              webDomains: familyActivitySelection.webDomainTokens,
              threshold: threshold
            )
          }

          return (
            DeviceActivityEvent.Name(eventRaw.eventName),
            event
          )
        })

      let activityName = DeviceActivityName(activityName)

      try center.startMonitoring(
        activityName,
        during: schedule,
        events: dictionary
      )
      logger.log(
        "✅ Succeeded with Starting Monitor Activity: \(activityName.rawValue, privacy: .public)")

    }

    Function("reloadDeviceActivityCenter") {
      // probably should be done, but is not entirely intuitive so doing it in userland
      // center.stopMonitoring()

      center = DeviceActivityCenter()

      watchActivitiesHandle?.cancel()
      watchActivitiesHandle = center.activities.publisher.sink { activity in
        self.sendEvent(
          "onDeviceActivityDetected" as String,
          [
            "activityName": activity.rawValue
          ])
      }
    }

    Function("stopMonitoring") { (activityNames: [String]?) in
      if activityNames == nil || activityNames?.count == 0 {
        center.stopMonitoring()
        return
      }
      center.stopMonitoring(
        activityNames!.map({ activityName in
          return DeviceActivityName(activityName)
        }))
    }

    Function("activities") {
      let activities = center.activities

      return activities.map { activity in
        return activity.rawValue
      }
    }

    AsyncFunction("requestAuthorization") { (forIndividualOrChild: String?) in
      let ac = AuthorizationCenter.shared

      if #available(iOS 16.0, *) {
        try await ac.requestAuthorization(
          for: forIndividualOrChild == "child" ? .child : .individual)
      } else {
        let errorMessage = "iOS 16.0 or later is required to request authorization."
        logger.log("⚠️ \(errorMessage)")
        throw NSError(
          domain: "FamilyControls",
          code: 9999,
          userInfo: [NSLocalizedDescriptionKey: errorMessage]
        )
      }
    }

    Function("intersection") {
      (
        familyActivitySelection: [String: Any], familyActivitySelection2: [String: Any],
        options: [String: Any]
      )
        -> ActivitySelectionWithMetadata in
      let selection1 = parseActivitySelectionInput(input: familyActivitySelection)

      let selection2 = parseActivitySelectionInput(input: familyActivitySelection2)

      let selection = intersection(selection1, selection2)

      if let persistAsActivitySelectionId = options["persistAsActivitySelectionId"] as? String {
        setFamilyActivitySelectionById(
          id: persistAsActivitySelectionId, activitySelection: selection)
      }

      let stripToken = options["stripToken"] as? Bool ?? false

      return ActivitySelectionWithMetadata(
        activitySelection: selection,
        stripToken: stripToken
      )
    }

    Function("union") {
      (
        familyActivitySelection: [String: Any], familyActivitySelection2: [String: Any],
        options: [String: Any]
      )
        -> ActivitySelectionWithMetadata in
      let selection1 = parseActivitySelectionInput(input: familyActivitySelection)

      let selection2 = parseActivitySelectionInput(input: familyActivitySelection2)

      let selection = union(selection1, selection2)

      if let persistAsActivitySelectionId = options["persistAsActivitySelectionId"] as? String {
        setFamilyActivitySelectionById(
          id: persistAsActivitySelectionId, activitySelection: selection)
      }

      let stripToken = options["stripToken"] as? Bool ?? false

      return ActivitySelectionWithMetadata(
        activitySelection: selection,
        stripToken: stripToken
      )
    }

    Function("difference") {
      (
        familyActivitySelection: [String: Any], familyActivitySelection2: [String: Any],
        options: [String: Any]
      )
        -> ActivitySelectionWithMetadata in
      let selection1 = parseActivitySelectionInput(input: familyActivitySelection)

      let selection2 = parseActivitySelectionInput(input: familyActivitySelection2)

      let selection = difference(selection1, selection2)

      if let persistAsActivitySelectionId = options["persistAsActivitySelectionId"] as? String {
        setFamilyActivitySelectionById(
          id: persistAsActivitySelectionId, activitySelection: selection)
      }

      let stripToken = options["stripToken"] as? Bool ?? false

      return ActivitySelectionWithMetadata(
        activitySelection: selection,
        stripToken: stripToken
      )
    }

    Function("symmetricDifference") {
      (
        familyActivitySelection: [String: Any], familyActivitySelection2: [String: Any],
        options: [String: Any]
      )
        -> ActivitySelectionWithMetadata in
      let selection1 = parseActivitySelectionInput(input: familyActivitySelection)

      let selection2 = parseActivitySelectionInput(input: familyActivitySelection2)

      let selection = symmetricDifference(selection1, selection2)

      if let persistAsActivitySelectionId = options["persistAsActivitySelectionId"] as? String {
        setFamilyActivitySelectionById(
          id: persistAsActivitySelectionId, activitySelection: selection)
      }

      let stripToken = options["stripToken"] as? Bool ?? false

      return ActivitySelectionWithMetadata(
        activitySelection: selection,
        stripToken: stripToken
      )
    }

    Function("renameActivitySelection") {
      (
        previousFamilyActivitySelectionId: String,
        newFamilyActivitySelectionId: String
      ) in
      renameFamilyActivitySelectionId(
        previousId: previousFamilyActivitySelectionId, newId: newFamilyActivitySelectionId)
    }

    Function("activitySelectionMetadata") {
      (familyActivitySelection: [String: Any]) -> ActivitySelectionMetadata in
      let selection = parseActivitySelectionInput(input: familyActivitySelection)

      return ActivitySelectionMetadata(
        activitySelection: selection
      )
    }

    Function("activitySelectionWithMetadata") {
      (familyActivitySelection: [String: Any]) -> ActivitySelectionWithMetadata in
      let selection = parseActivitySelectionInput(input: familyActivitySelection)

      return ActivitySelectionWithMetadata(
        activitySelection: selection
      )
    }

    Function("isShieldActive") {
      return isShieldActive()
    }

    Function("blockSelection") {
      (familyActivitySelection: [String: Any], triggeredBy: String?) in
      let triggeredBy = triggeredBy ?? "blockSelection called manually"

      let activitySelection = parseActivitySelectionInput(input: familyActivitySelection)

      blockSelectedApps(
        blockSelection: activitySelection,
        triggeredBy: triggeredBy
      )

      let blockingAllModeEnabled = isBlockingAllModeEnabled()

      if blockingAllModeEnabled {
        throw TryingToBlockSelectionWhenBlockModeIsEnabledError()
      }
    }

    Function("resetBlocks") { (triggeredBy: String?) in
      resetBlocks(triggeredBy: triggeredBy ?? "resetBlocks called manually")
    }

    Function("isBlockingAllModeEnabled") { () -> Bool in
      // block all apps
      return isBlockingAllModeEnabled()
    }

    Function("enableBlockAllMode") { (triggeredBy: String?) in
      // block all apps
      enableBlockAllMode(
        triggeredBy: triggeredBy ?? "enableBlockAllMode called manually"
      )
    }

    Function("disableBlockAllMode") { (triggeredBy: String?) in
      disableBlockAllMode(
        triggeredBy: triggeredBy ?? "disableBlockAllMode called manually"
      )
    }

    Function("removeSelectionFromWhitelistAndUpdateBlock") {
      (familyActivitySelection: [String: Any], triggeredBy: String?) throws in
      let triggeredBy = triggeredBy ?? "removeSelectionFromWhitelistAndUpdateBlock called manually"

      let activitySelection = parseActivitySelectionInput(input: familyActivitySelection)

      removeSelectionFromWhitelistAndUpdateBlock(
        selection: activitySelection, triggeredBy: triggeredBy)

      if #available(iOS 15.2, *) {
        if !activitySelection.includeEntireCategory {
          throw WhitelistSelectionWithoutEntireCategoryError()
        }
      } else {
        throw WhitelistSelectionWithoutEntireCategoryError()
      }
    }

    Function("addSelectionToWhitelistAndUpdateBlock") {
      (familyActivitySelection: [String: Any], triggeredBy: String?) throws in
      let triggeredBy = triggeredBy ?? "addSelectionToWhitelistAndUpdateBlock called manually"

      let activitySelection = parseActivitySelectionInput(input: familyActivitySelection)

      addSelectionToWhitelistAndUpdateBlock(
        whitelistSelection: activitySelection,
        triggeredBy: triggeredBy
      )

      if #available(iOS 15.2, *) {
        if !activitySelection.includeEntireCategory {
          throw WhitelistSelectionWithoutEntireCategoryError()
        }
      } else {
        throw WhitelistSelectionWithoutEntireCategoryError()
      }
    }

    Function("clearWhitelistAndUpdateBlock") {
      (triggeredBy: String?) in
      clearWhitelist()

      updateBlock(triggeredBy: triggeredBy ?? "clearWhitelistAndUpdateBlock called manually")
    }

    Function("clearWhitelist") {
      clearWhitelist()
    }

    AsyncFunction("revokeAuthorization") { () async throws in
      let ac = AuthorizationCenter.shared

      return try await withCheckedThrowingContinuation { continuation in
        ac.revokeAuthorization { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            logger.log(
              "❌ Failed to revoke authorization: \(error.localizedDescription, privacy: .public)")
            continuation.resume(throwing: error)
          }
        }
      }
    }

    Events(
      "onSelectionChange",
      "onDeviceActivityMonitorEvent",
      // "onManagedStoreWillChange",
      "onDeviceActivityDetected",
      "onAuthorizationStatusChange"
    )

    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    View(ReactNativeDeviceActivityView.self) {
      Events(
        "onSelectionChange"
      )
      // Defines a setter for the `name` prop.
      Prop("familyActivitySelection") { (view: ReactNativeDeviceActivityView, prop: String) in
        let selection = deserializeFamilyActivitySelection(familyActivitySelectionStr: prop)

        view.model.activitySelection = selection
      }

      Prop("footerText") { (view: ReactNativeDeviceActivityView, prop: String?) in
        view.model.footerText = prop
      }

      Prop("headerText") { (view: ReactNativeDeviceActivityView, prop: String?) in
        view.model.headerText = prop
      }
    }
  }
}

@available(iOS 15.0, *)
public class ReactNativeDeviceActivityViewPersistedModule: Module {
  public func definition() -> ExpoModulesCore.ModuleDefinition {
    Name("ReactNativeDeviceActivityViewPersistedModule")
    View(ReactNativeDeviceActivityViewPersisted.self) {
      Events(
        "onSelectionChange"
      )
      // Defines a setter for the `name` prop.
      Prop("familyActivitySelectionId") {
        (view: ReactNativeDeviceActivityViewPersisted, prop: String) in
        view.model.activitySelectionId = prop
        if let includeEntireCategory = view.model.includeEntireCategory {
          let selection =
            getFamilyActivitySelectionById(
              id: prop
            ) ?? FamilyActivitySelection(includeEntireCategory: includeEntireCategory)

          view.model.activitySelection = selection

        }
      }

      // note: this property will only have an effect on new selections
      Prop("includeEntireCategory") { (view: ReactNativeDeviceActivityViewPersisted, prop: Bool?) in
        view.model.includeEntireCategory = prop
        if let activitySelectionId = view.model.activitySelectionId {
          let selection =
            getFamilyActivitySelectionById(
              id: activitySelectionId
            )
            ?? FamilyActivitySelection(
              includeEntireCategory: prop ?? false
            )

          view.model.activitySelection = selection
        }
      }

      Prop("footerText") { (view: ReactNativeDeviceActivityViewPersisted, prop: String?) in
        view.model.footerText = prop
      }

      Prop("headerText") { (view: ReactNativeDeviceActivityViewPersisted, prop: String?) in
        view.model.headerText = prop
      }
    }
  }
}
