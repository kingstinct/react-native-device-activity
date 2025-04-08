//
//  UnionTests.swift
//
//  Created by Robert Herber on 2025-03-07.
//

import FamilyControls
import ManagedSettings
import Testing

@Suite(.serialized) struct IsShieldActiveTests {

  @Test func shieldIsNotActive() async throws {
    store.shield.applicationCategories = nil
    store.shield.applications = nil
    store.shield.webDomainCategories = nil
    store.shield.webDomains = nil

    let isActive = isShieldActive()

    #expect(!isActive)
  }

  @Test func shieldIsActive() async throws {
    let emptySelection = FamilyActivitySelection()

    updateBlockInternal(
      isBlockingAllModeEnabled: true,
      currentBlocklist: emptySelection,
      currentWhitelist: emptySelection
    )

    let isActive = isShieldActive()

    #expect(isActive)
  }

  // not optimal behaviour but we have no way to get a different behaviour from the simulator
  @Test func shieldIsFullyWhitelisted() async throws {
    let everything = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverything
    )

    store.shield.applicationCategories =
      .all(except: everything.applicationTokens)
    store.shield.webDomainCategories =
      .all(except: everything.webDomainTokens)

    let isActive = isShieldActive()

    #expect(isActive)
  }

  // not optimal behaviour but we have no way to get a different behaviour from the simulator
  @Test func isShieldEmptyForEmptySelection() async throws {
    let emptySelection = FamilyActivitySelection()

    updateBlockInternal(
      isBlockingAllModeEnabled: false,
      currentBlocklist: emptySelection,
      currentWhitelist: emptySelection
    )

    let isActive = isShieldActive()

    #expect(!isActive)
  }
}
