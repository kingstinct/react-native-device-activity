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
      onlyFamilySelectionIdsContainingMonitoredActivityNames: false
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
      categoryToken: token.categoryTokens.first
    )

    XCTAssertEqual(
      activitySelectionPrefixedConfigKey, nil
    )
  }

  func testGetActivitySelectionPrefixedConfigFromUserDefaultsWhenThereIsNoActivitySelectionId() {
    let token = deserializeFamilyActivitySelection(familyActivitySelectionStr: tokenIncludingSocial)

    let activitySelectionPrefixedConfigKey = tryGetActivitySelectionIdConfigKey(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      categoryToken: token.categoryTokens.first
    )

    XCTAssertEqual(
      activitySelectionPrefixedConfigKey, nil
    )
  }

  func testGetPossibleFamilyActivitySelectionIdsSorted() {
    let tokenWithSocial = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingSocial)

    setFamilyActivitySelectionById(id: "social", activitySelection: tokenWithSocial)
    setFamilyActivitySelectionById(
      id: "everything",
      activitySelection: deserializeFamilyActivitySelection(
        familyActivitySelectionStr: tokenIncludingEverythingWithCategories
      ))

    let matches = getPossibleFamilyActivitySelectionIds(
      categoryToken: tokenWithSocial.categoryTokens.first,
      onlyFamilySelectionIdsContainingMonitoredActivityNames: false
    )

    XCTAssertEqual(
      matches.map({ token in
        token.id
      }), ["social", "everything"])
  }

  func testGetPossibleFamilyActivitySelectionIdsOnlyMatches() {
    let tokenWithGames = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )

    setFamilyActivitySelectionById(
      id: "social",
      activitySelection: deserializeFamilyActivitySelection(
        familyActivitySelectionStr: tokenIncludingSocial))
    setFamilyActivitySelectionById(
      id: "everything",
      activitySelection: deserializeFamilyActivitySelection(
        familyActivitySelectionStr: tokenIncludingEverythingWithCategories
      ))
    setFamilyActivitySelectionById(id: "games", activitySelection: tokenWithGames)

    let matches = getPossibleFamilyActivitySelectionIds(
      categoryToken: tokenWithGames.categoryTokens.first,
      onlyFamilySelectionIdsContainingMonitoredActivityNames: false
    )

    XCTAssertEqual(
      matches.map({ token in
        token.id
      }), ["games", "everything"])
  }

  func testGetPossibleFamilyActivitySelectionIdsOnlySortedAllOfIt() {
    let tokenWithGames = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )

    let tokenWithSocial = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingSocial)

    let socialAndGames = union(tokenWithGames, tokenWithSocial)

    setFamilyActivitySelectionById(
      id: "social",
      activitySelection: tokenWithSocial
    )
    setFamilyActivitySelectionById(
      id: "everything",
      activitySelection: deserializeFamilyActivitySelection(
        familyActivitySelectionStr: tokenIncludingEverythingWithCategories
      ))
    setFamilyActivitySelectionById(id: "games", activitySelection: tokenWithGames)
    setFamilyActivitySelectionById(
      id: "social-and-games",
      activitySelection: socialAndGames
    )

    let matches = getPossibleFamilyActivitySelectionIds(
      categoryToken: tokenWithGames.categoryTokens.first,
      onlyFamilySelectionIdsContainingMonitoredActivityNames: false
    )

    XCTAssertEqual(
      matches.map({ token in
        token.id
      }), ["games", "social-and-games", "everything"])
  }
}
