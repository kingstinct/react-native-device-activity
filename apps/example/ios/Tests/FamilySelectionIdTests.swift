//
//  familySelectionIdTests.swift
//  reactnativedeviceactivityexample
//
//  Created by Robert Herber on 2025-03-06.
//

import FamilyControls
import XCTest

class FamilySelectionIdTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Set up any test data in userDefaults
    userDefaults?.removeObject(forKey: FAMILY_ACTIVITY_SELECTION_ID_KEY)
  }

  func testShouldHaveOne() {
    setFamilyActivitySelectionById(
      id: "my-id",
      activitySelection: FamilyActivitySelection()
    )

    let ids = getFamilyActivitySelectionIds()
    XCTAssertEqual(ids.count, 1)
  }

  func testShouldGetNonExistent() {
    let empty = getFamilyActivitySelectionById(
      id: "non-existent"
    )

    XCTAssertEqual(empty, nil)
  }

  func testShouldHaveTwo() {
    setFamilyActivitySelectionById(
      id: "my-id",
      activitySelection: FamilyActivitySelection()
    )

    setFamilyActivitySelectionById(
      id: "my-id",
      activitySelection: FamilyActivitySelection()
    )

    setFamilyActivitySelectionById(
      id: "my-id-2",
      activitySelection: FamilyActivitySelection()
    )

    let ids = getFamilyActivitySelectionIds()
    XCTAssertEqual(ids.count, 2)
  }

  func testShouldEqualSavedOne() {
    setFamilyActivitySelectionById(
      id: "my-id",
      activitySelection: FamilyActivitySelection()
    )

    let familySelection = getFamilyActivitySelectionById(id: "my-id")
    XCTAssertEqual(familySelection, FamilyActivitySelection())
  }

  func testRemoveFamilyActivitySelectionById() {
    setFamilyActivitySelectionById(
      id: "my-id",
      activitySelection: FamilyActivitySelection()
    )

    removeFamilyActivitySelectionById(id: "my-id")
    let familySelection = getFamilyActivitySelectionById(id: "my-id")
    let ids = getFamilyActivitySelectionIds()
    XCTAssertEqual(familySelection, nil)
    XCTAssertEqual(ids.count, 0)
  }

  func testGetActivitySelectionPrefixedConfigFromUserDefaults() {
    let id = "my-id-with-shield-config"

    let token = deserializeFamilyActivitySelection(familyActivitySelectionStr: tokenIncludingSocial)

    setFamilyActivitySelectionById(
      id: id,
      activitySelection: token
    )

    userDefaults?.set([:], forKey: "shieldConfigurationForSelection_my-id-with-shield-config")

    let activitySelectionPrefixedConfigKey = tryGetActivitySelectionIdConfigKey(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      categoryToken: token.categoryTokens.first,
    )

    XCTAssertEqual(
      activitySelectionPrefixedConfigKey, "shieldConfigurationForSelection_my-id-with-shield-config"
    )
  }

  func testGetActivitySelectionPrefixedConfigFromUserDefaultsWhenThereIsNoConfig() {
    let id = "my-id-with-shield-config-2"

    let token = deserializeFamilyActivitySelection(familyActivitySelectionStr: tokenIncludingSocial)

    setFamilyActivitySelectionById(
      id: id,
      activitySelection: token
    )

    let activitySelectionPrefixedConfigKey = tryGetActivitySelectionIdConfigKey(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      categoryToken: token.categoryTokens.first,
    )

    XCTAssertEqual(
      activitySelectionPrefixedConfigKey, nil
    )
  }

  func testGetActivitySelectionPrefixedConfigFromUserDefaultsWhenThereIsNoActivitySelectionId() {
    let token = deserializeFamilyActivitySelection(familyActivitySelectionStr: tokenIncludingSocial)

    let activitySelectionPrefixedConfigKey = tryGetActivitySelectionIdConfigKey(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      categoryToken: token.categoryTokens.first,
    )

    XCTAssertEqual(
      activitySelectionPrefixedConfigKey, nil
    )
  }
}
