import XCTest

class SharedTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Set up any test data in userDefaults
    userDefaults?.set("Bearer token123", forKey: "AUTH_HEADER")
  }

  override func tearDown() {
    // Clean up userDefaults after tests
    userDefaults?.removeObject(forKey: "AUTH_HEADER")
    super.tearDown()
  }

  func testBasicStringReplacement() {
    let input: [String: Any] = ["name": "Hello {username}!"]
    let placeholders = ["username": "John"]
    let result = replacePlaceholdersInObject(input, with: placeholders)
    XCTAssertEqual(result["name"] as? String, "Hello John!")
  }

  func testUserDefaultsSpecialTreatment() {
    let input: [String: Any] = ["auth": "{userDefaults:AUTH_HEADER}"]
    let result = replacePlaceholdersInObject(input, with: [:])
    XCTAssertEqual(result["auth"] as? String, "Bearer token123")
  }

  func testAsNumberSpecialTreatment() {
    let input: [String: Any] = ["count": "{asNumber:value}"]
    let placeholders = ["value": "42"]
    let result = replacePlaceholdersInObject(input, with: placeholders)
    XCTAssertEqual(result["count"] as? Double, 42.0)
  }

  func testMixedReplacements() {
    let input: [String: Any] = [
      "greeting": "Hello {name}!",
      "auth": "{userDefaults:AUTH_HEADER}",
      "score": "{asNumber:points}"
    ]
    let placeholders = ["name": "Alice", "points": "100"]
    let result = replacePlaceholdersInObject(input, with: placeholders)

    XCTAssertEqual(result["greeting"] as? String, "Hello Alice!")
    XCTAssertEqual(result["auth"] as? String, "Bearer token123")
    XCTAssertEqual(result["score"] as? Double, 100.0)
  }

  func testNonStringValuesRemainUnchanged() {
    let input: [String: Any] = [
      "name": "Hello {username}!",
      "age": 25,
      "isActive": true
    ]
    let placeholders = ["username": "Bob"]
    let result = replacePlaceholdersInObject(input, with: placeholders)

    XCTAssertEqual(result["name"] as? String, "Hello Bob!")
    XCTAssertEqual(result["age"] as? Int, 25)
    XCTAssertEqual(result["isActive"] as? Bool, true)
  }

  func testNullEdgeCase() {
    let input: [String: Any] = [
      "name": "Hello {username}!",
      "auth": "{userDefaults:NON_EXISTENT_KEY}",
      "score": "{asNumber:missingValue}"
    ]
    let placeholders: [String: String] = [:]
    let result = replacePlaceholdersInObject(input, with: placeholders)

    XCTAssertEqual(result["name"] as? String, "Hello {username}!")
    XCTAssertEqual(result["auth"] as? String, "{userDefaults:NON_EXISTENT_KEY}")
    XCTAssertEqual(result["score"] as? String, "{asNumber:missingValue}")
  }
}

class SkipActionTests: XCTestCase {
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
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

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
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

}

class MoreSkipActionTests: XCTestCase {
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
      skipIfAlreadyTriggeredBetweenFromDate: 1000,
      skipIfAlreadyTriggeredBetweenToDate: 1500,
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
      skipIfAlreadyTriggeredBetweenToDate: 1000,
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
      activityName: activityName,
      callbackName: callbackName,
      eventName: eventName
    )

    XCTAssertFalse(shouldNotExecute)
    XCTAssertTrue(shouldExecute)
  }

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
      activityName: activityName,
      callbackName: callbackName,
      eventName: "5"
    )

    XCTAssertTrue(shouldExecute)
    XCTAssertFalse(shouldNotExecute)
  }

  func testIsHigherEventNum() {
    let isLower = isHigherEvent(eventName: "5", higherThan: "10")
    let isEqual = isHigherEvent(eventName: "10", higherThan: "10")
    let isHigher = isHigherEvent(eventName: "15", higherThan: "10")

    XCTAssertTrue(isHigher)
    XCTAssertFalse(isEqual)
    XCTAssertFalse(isLower)
  }

  func testIsHigherEventString() {
    let isHigherBecauseString = isHigherEvent(eventName: "prefix_5", higherThan: "prefix_10")
    let isEqual = isHigherEvent(eventName: "prefix_10", higherThan: "prefix_10")
    let isHigher = isHigherEvent(eventName: "prefix_15", higherThan: "prefix_10")

    XCTAssertTrue(isHigher)
    XCTAssertFalse(isEqual)
    XCTAssertTrue(isHigherBecauseString)
  }

  func testReplaceText() {
    let five = removePrefixIfPresent(
      key: "event_with_prefix_5",
      prefix: "event_with_prefix_"
    )

    let empty = removePrefixIfPresent(
      key: "event_with_prefix_",
      prefix: "event_with_prefix_"
    )

    let nonmatching = removePrefixIfPresent(
      key: "dfgsfgsdfgsdfg",
      prefix: "event_with_prefix_"
    )

    XCTAssertEqual(five, "5")
    XCTAssertEqual(empty, "")
    XCTAssertEqual(nonmatching, "dfgsfgsdfgsdfg")
  }
}
