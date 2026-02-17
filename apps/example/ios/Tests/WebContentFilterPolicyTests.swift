import ManagedSettings
import XCTest

@available(iOS 15.0, *)
class WebContentFilterPolicyTests: XCTestCase {
  override func setUp() {
    super.setUp()
    clearWebContentFilterPolicy(triggeredBy: "WebContentFilterPolicyTests.setUp")
  }

  override func tearDown() {
    clearWebContentFilterPolicy(triggeredBy: "WebContentFilterPolicyTests.tearDown")
    super.tearDown()
  }

  func testAutoPolicyParsesDomainsAndExceptions() throws {
    let parsed = try parseWebContentFilterPolicyInput(
      policyInput: [
        "type": "auto",
        "domains": [
          "https://adult.example.com/path"
        ],
        "exceptDomains": [
          "safe.example.com"
        ]
      ]
    )

    switch parsed.policy {
    case .auto(let domains, except: let exceptDomains):
      XCTAssertEqual(domains.compactMap(\.domain).sorted(), ["adult.example.com"])
      XCTAssertEqual(exceptDomains.compactMap(\.domain).sorted(), ["safe.example.com"])
    default:
      XCTFail("Expected auto policy")
    }
  }

  func testSpecificPolicyRejectsMoreThanFiftyDomains() {
    // 51 unique domains should fail (Apple limit is 50)
    let domains = (1...51).map { index in
      return "blocked-\(index).example.com"
    }

    XCTAssertThrowsError(
      try parseWebContentFilterPolicyInput(
        policyInput: [
          "type": "specific",
          "domains": domains
        ]
      )
    )
  }

  func testSpecificPolicyAllowsExactlyFiftyDomains() throws {
    let domains = (1...50).map { index in
      return "blocked-\(index).example.com"
    }

    let parsed = try parseWebContentFilterPolicyInput(
      policyInput: [
        "type": "specific",
        "domains": domains
      ]
    )

    switch parsed.policy {
    case .specific(let parsedDomains):
      XCTAssertEqual(parsedDomains.count, 50)
    default:
      XCTFail("Expected specific policy")
    }
  }

  func testAllPolicyRejectsMoreThanFiftyExceptions() {
    // 51 unique domains should fail (Apple limit is 50)
    let domains = (1...51).map { index in
      return "allowed-\(index).example.com"
    }

    XCTAssertThrowsError(
      try parseWebContentFilterPolicyInput(
        policyInput: [
          "type": "all",
          "exceptDomains": domains
        ]
      )
    )
  }

  func testAutoPolicyNormalizesQueryAndFragmentDomains() throws {
    let parsed = try parseWebContentFilterPolicyInput(
      policyInput: [
        "type": "auto",
        "domains": ["example.com?foo=1"],
        "exceptDomains": ["safe.example.com#top"]
      ]
    )

    switch parsed.policy {
    case .auto(let domains, except: let exceptDomains):
      XCTAssertEqual(domains.compactMap(\.domain).sorted(), ["example.com"])
      XCTAssertEqual(exceptDomains.compactMap(\.domain).sorted(), ["safe.example.com"])
    default:
      XCTFail("Expected auto policy")
    }
  }

  func testClearPolicyDeactivatesFilter() throws {
    try setWebContentFilterPolicy(
      policyInput: [
        "type": "auto"
      ],
      triggeredBy: "WebContentFilterPolicyTests.testClearPolicyDeactivatesFilter"
    )

    XCTAssertTrue(isWebContentFilterPolicyActive())

    clearWebContentFilterPolicy(
      triggeredBy: "WebContentFilterPolicyTests.testClearPolicyDeactivatesFilter"
    )

    XCTAssertFalse(isWebContentFilterPolicyActive())
  }

  func testExecuteGenericActionAppliesAndClearsPolicy() {
    executeGenericAction(
      action: [
        "type": "setWebContentFilterPolicy",
        "policy": [
          "type": "auto",
          "domains": ["adult.example.com"],
          "exceptDomains": ["safe.example.com"]
        ]
      ],
      placeholders: [:],
      triggeredBy: "WebContentFilterPolicyTests.testExecuteGenericActionAppliesAndClearsPolicy"
    )

    XCTAssertTrue(isWebContentFilterPolicyActive())

    executeGenericAction(
      action: [
        "type": "clearWebContentFilterPolicy"
      ],
      placeholders: [:],
      triggeredBy: "WebContentFilterPolicyTests.testExecuteGenericActionAppliesAndClearsPolicy"
    )

    XCTAssertFalse(isWebContentFilterPolicyActive())
  }
}
