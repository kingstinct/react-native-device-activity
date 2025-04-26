import FamilyControls
import XCTest

class NeverTriggerBeforeTests: XCTestCase {
  func testNeverTriggerBefore() {
    let activityName = "myActivityWithSkipIfAlreadyTriggeredAfter"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"

    let shouldTriggerTime = Date().timeIntervalSince1970 * 1000 - 10000
    let shouldNotTriggerTime = Date().timeIntervalSince1970 * 1000 + 10000

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: shouldNotTriggerTime,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: shouldTriggerTime,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

}

class SkipIfTriggeredBeforeTests: XCTestCase {

  func testSkipIfAlreadyTriggeredBefore() {
    let activityName = "myActivityWithSkipIfAlreadyTriggeredBefore"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    userDefaults?.set(1000, forKey: key)

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: 1001,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: 1000,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

}

class SkipIfAlreadyTriggeredBetweenTests: XCTestCase {
  func testShouldSkipIfAlreadyTriggeredBetween() {
    let activityName = "myActivityWithSkipIfAlreadyTriggeredBetween"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    userDefaults?.set(1000, forKey: key)

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: 500,
      skipIfAlreadyTriggeredBetweenToDate: 1500,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: 1001,
      skipIfAlreadyTriggeredBetweenToDate: 1500,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldAlsoExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: 500,
      skipIfAlreadyTriggeredBetweenToDate: 999,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
    XCTAssertTrue(shouldAlsoExecute)
  }

  func testShouldSkipIfAlreadyTriggeredAfter() {
    let activityName = "myActivityWithSkipIfAlreadyTriggeredAfter"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    userDefaults?.set(1000, forKey: key)

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: 999,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: 1000,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

  func testSkipIfAlreadyTriggeredWithinMS() {
    let activityName = "myActivity"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let time = Date.now.addingTimeInterval(-1)

    userDefaults?.set(time.timeIntervalSince1970 * 1000, forKey: key)

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: 100,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: 10000,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertTrue(shouldExecute)
    XCTAssertFalse(shouldNotExecute)
  }

  func testShouldSkipIfLargerTriggeredAfter() {
    let activityName = "myActivity"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let higherThanEventName = "15"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: higherThanEventName
    )

    userDefaults?.set(1000, forKey: key)

    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: 999,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: 1000,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

}

class SkipIfLargerTests: XCTestCase {

  func testSkipIfLargerTriggeredWithinMS() {
    let activityName = "myActivitySkipIfLargerEventRecordedWithinMS"
    let callbackName = "eventDidReachThreshold"
    let eventName = "10"
    let higherThanEventName = "15"
    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: higherThanEventName
    )

    let time = Date.now.addingTimeInterval(-1)

    userDefaults?.set(time.timeIntervalSince1970 * 1000, forKey: key)

    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: 100,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: 10000,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: false,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertTrue(shouldExecute)
    XCTAssertFalse(shouldNotExecute)
  }

  func testSkipIfLargerTriggeredAfterIntervalStarted() {
    let activityName = "myActivity"
    let callbackName = "eventDidReachThreshold"

    let key = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: callbackName,
      eventName: "10"
    )

    let keyForMonitoringStarted = userDefaultKeyForEvent(
      activityName: activityName,
      callbackName: "intervalDidStart"
    )

    let time = Date.now.addingTimeInterval(-1)
    let intervalStartTime = Date.now.addingTimeInterval(-2)

    userDefaults?.set(time.timeIntervalSince1970 * 1000, forKey: key)
    userDefaults?.set(
      intervalStartTime.timeIntervalSince1970 * 1000, forKey: keyForMonitoringStarted)

    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

    let shouldExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: true,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: "15"
    )

    let shouldNotExecute = shouldExecuteAction(
      skipIfAlreadyTriggeredAfter: nil,
      skipIfLargerEventRecordedAfter: nil,
      skipIfAlreadyTriggeredWithinMS: nil,
      skipIfLargerEventRecordedWithinMS: nil,
      neverTriggerBefore: nil,
      skipIfLargerEventRecordedSinceIntervalStarted: true,
      skipIfAlreadyTriggeredBefore: nil,
      skipIfAlreadyTriggeredBetweenFromDate: nil,
      skipIfAlreadyTriggeredBetweenToDate: nil,
      skipIfWhitelistOrBlacklistIsUnchanged: false,
      originalWhitelist: FamilyActivitySelection(),
      originalBlocklist: FamilyActivitySelection(),
      activityName: activityName,
      callbackName: callbackName,
      eventName: "5"
    )

    XCTAssertTrue(shouldExecute)
    XCTAssertFalse(shouldNotExecute)
  }
}
