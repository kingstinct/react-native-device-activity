//
//  ComparisonTests.swift
//  reactnativedeviceactivityexample
//
//  Created by Robert Herber on 2025-03-06.
//

import XCTest

class ComparisonTests: XCTestCase {

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
