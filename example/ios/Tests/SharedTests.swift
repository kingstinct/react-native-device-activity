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

class SharedTests2: XCTestCase {
  func isHigherEventNumTest() {
    let isLower = isHigherEvent(eventName: "5", higherThan: "10")
    let isEqual = isHigherEvent(eventName: "10", higherThan: "10")
    let isHigher = isHigherEvent(eventName: "15", higherThan: "10")

    XCTAssertTrue(isHigher)
    XCTAssertFalse(isEqual)
    XCTAssertFalse(isLower)
  }

  func isHigherEventStringTest() {
    let isHigherBecauseString = isHigherEvent(eventName: "prefix_5", higherThan: "prefix_10")
    let isEqual = isHigherEvent(eventName: "prefix_10", higherThan: "prefix_10")
    let isHigher = isHigherEvent(eventName: "prefix_15", higherThan: "prefix_10")

    XCTAssertTrue(isHigher)
    XCTAssertFalse(isEqual)
    XCTAssertFalse(isHigherBecauseString)
  }

  func replaceTest() {
    let five = replace(
      key: "event_with_prefix_5",
      prefix: "event_with_prefix_"
    )

    let empty = replace(
      key: "event_with_prefix_",
      prefix: "event_with_prefix_"
    )

    let nonmatching = replace(
      key: "dfgsfgsdfgsdfg",
      prefix: "event_with_prefix_"
    )

    XCTAssertEqual(five, "5")
    XCTAssertEqual(empty, "")
    XCTAssertEqual(nonmatching, "dfgsfgsdfgsdfg")
  }
}
