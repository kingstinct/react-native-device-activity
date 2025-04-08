//
//  UnionTests.swift
//
//  Created by Robert Herber on 2025-03-07.
//

import FamilyControls
import ManagedSettings
import Testing

let tokenIncludingEverything =
  "eyJ1bnRva2VuaXplZFdlYkRvbWFpbklkZW50aWZpZXJzIjpbXSwidW50b2tlbml6ZWRBcHBsaWNhdGlvbklkZW50aWZpZXJzIjpbXSwiaW5jbHVkZUVudGlyZUNhdGVnb3J5IjpmYWxzZSwidW50b2tlbml6ZWRDYXRlZ29yeUlkZW50aWZpZXJzIjpbXSwiY2F0ZWdvcnlUb2tlbnMiOlt7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWFPMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME0zTkNCbUNsZ1hSaHVHdlBuc2JPQ0hZPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1YnUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTA1enJkVFd3WVZLVmNSN1VSbTNCbzg9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXVZdTJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNelFRK3J3d1FHY2RqcHNTenFkRkczMD0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWIrMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME14c0VIcDArWGxMRytIYk5jN3pjaEZzPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl2YU8yS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTdPMXBVZjZ2R3Y1eDliXC84WnNTamZjPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1WSsyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTJGblNmWFkzN0NSSXltazdBSXVtYWs9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXViZTJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNN0hyZUE3dllmM2ZveE9oTnZZTGdmTT0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWFlMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME15WTF0U2xOSHFQdEZkbDV2R09saXFJPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2S0VVY051Szd5MmZUdDZvd1VrMDVobjVIc2U5aFlFRUs2VWVpWVdKektaNDQ1WDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTVwvaTVOb01ROTdIeFNISzdiNUZVald3PSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1Yk8yS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTStTY3kwY0hcL2lwVERxRVhGRk5nQXljPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1YXUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTltdFlQTjB2dHQ0NHc2ajI0d1pEZDQ9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXZhZTJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNK2JDRmc0U0k3eDFhbVJKMHo1NUR5TT0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdmF1MktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME14bGF3OVFyZzhUZ25MT1R0TkhGaUY4PSJ9XSwid2ViRG9tYWluVG9rZW5zIjpbXSwiYXBwbGljYXRpb25Ub2tlbnMiOltdfQ=="

let tokenIncludingSocial =
  "eyJ1bnRva2VuaXplZFdlYkRvbWFpbklkZW50aWZpZXJzIjpbXSwiY2F0ZWdvcnlUb2tlbnMiOlt7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWFlMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME15WTF0U2xOSHFQdEZkbDV2R09saXFJPSJ9XSwid2ViRG9tYWluVG9rZW5zIjpbXSwidW50b2tlbml6ZWRBcHBsaWNhdGlvbklkZW50aWZpZXJzIjpbXSwiaW5jbHVkZUVudGlyZUNhdGVnb3J5IjpmYWxzZSwidW50b2tlbml6ZWRDYXRlZ29yeUlkZW50aWZpZXJzIjpbXSwiYXBwbGljYXRpb25Ub2tlbnMiOltdfQ=="

let tokenIncludingGames =
  "eyJjYXRlZ29yeVRva2VucyI6W3siZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1YXUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTltdFlQTjB2dHQ0NHc2ajI0d1pEZDQ9In1dLCJhcHBsaWNhdGlvblRva2VucyI6W10sInVudG9rZW5pemVkQ2F0ZWdvcnlJZGVudGlmaWVycyI6W10sInVudG9rZW5pemVkQXBwbGljYXRpb25JZGVudGlmaWVycyI6W10sImluY2x1ZGVFbnRpcmVDYXRlZ29yeSI6ZmFsc2UsIndlYkRvbWFpblRva2VucyI6W10sInVudG9rZW5pemVkV2ViRG9tYWluSWRlbnRpZmllcnMiOltdfQ=="

let tokenIncludingEverythingWithCategories =
  "eyJhcHBsaWNhdGlvblRva2VucyI6W10sImNhdGVnb3J5VG9rZW5zIjpbeyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXZhTzJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNN08xcFVmNnZHdjV4OWJcLzhac1NqZmM9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXVZKzJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNMkZuU2ZYWTM3Q1JJeW1rN0FJdW1haz0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWFPMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME0zTkNCbUNsZ1hSaHVHdlBuc2JPQ0hZPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl2YXUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTXhsYXc5UXJnOFRnbkxPVHROSEZpRjg9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXViZTJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNN0hyZUE3dllmM2ZveE9oTnZZTGdmTT0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdmFlMktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME0rYkNGZzRTSTd4MWFtUkowejU1RHlNPSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1YnUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTTA1enJkVFd3WVZLVmNSN1VSbTNCbzg9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXVZdTJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNelFRK3J3d1FHY2RqcHNTenFkRkczMD0ifSx7ImRhdGEiOiJBQUFBQUFBQUFBQUFBQUFBdTFDVDdWbmlNa0FlWnB4elNRdTJHREV5amlJallTNWJrOFcrbWZwUUJORUNhN0IzMGlCcVl6cUJRNmVnRExJdWF1MktQMzFKb3hVbDNabHlyeVJQbVNabGY1TzRVdzh5QkJqMmxPRlgxXC9jemwrWmVvUzBXQXozb3FScmRKdjJsUFBmME05bXRZUE4wdnR0NDR3NmoyNHdaRGQ0PSJ9LHsiZGF0YSI6IkFBQUFBQUFBQUFBQUFBQUF1MUNUN1ZuaU1rQWVacHh6U1F1MkdERXlqaUlqWVM1Yms4VyttZnBRQk5FQ2E3QjMwaUJxWXpxQlE2ZWdETEl1YWUyS1AzMUpveFVsM1pseXJ5UlBtU1psZjVPNFV3OHlCQmoybE9GWDFcL2N6bCtaZW9TMFdBejNvcVJyZEp2MmxQUGYwTXlZMXRTbE5IcVB0RmRsNXZHT2xpcUk9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZLRVVjTnVLN3kyZlR0Nm93VWswNWhuNUhzZTloWUVFSzZVZWlZV0p6S1o0NDVYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNXC9pNU5vTVE5N0h4U0hLN2I1RlVqV3c9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXViTzJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNK1NjeTBjSFwvaXBURHFFWEZGTmdBeWM9In0seyJkYXRhIjoiQUFBQUFBQUFBQUFBQUFBQXUxQ1Q3Vm5pTWtBZVpweHpTUXUyR0RFeWppSWpZUzViazhXK21mcFFCTkVDYTdCMzBpQnFZenFCUTZlZ0RMSXViKzJLUDMxSm94VWwzWmx5cnlSUG1TWmxmNU80VXc4eUJCajJsT0ZYMVwvY3psK1plb1MwV0F6M29xUnJkSnYybFBQZjBNeHNFSHAwK1hsTEcrSGJOYzd6Y2hGcz0ifV0sImluY2x1ZGVFbnRpcmVDYXRlZ29yeSI6dHJ1ZSwidW50b2tlbml6ZWRBcHBsaWNhdGlvbklkZW50aWZpZXJzIjpbXSwidW50b2tlbml6ZWRDYXRlZ29yeUlkZW50aWZpZXJzIjpbXSwidW50b2tlbml6ZWRXZWJEb21haW5JZGVudGlmaWVycyI6W10sIndlYkRvbWFpblRva2VucyI6W119"

struct UnionTests {

  @Test func emptyIntersection() async throws {
    let result = intersection(FamilyActivitySelection(), FamilyActivitySelection())

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 0)
  }

  @Test func emptyUnion() async throws {
    let result = union(FamilyActivitySelection(), FamilyActivitySelection())

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 0)
  }

  @Test func fullUnion() async throws {
    let selectionIncludingAll = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverythingWithCategories
    )
    let result = union(selectionIncludingAll, FamilyActivitySelection())

    #expect(result.categoryTokens.count == 13)
    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
  }

  @Test func unionOfTwo() async throws {
    let selectionIncludingSocial = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingSocial
    )
    let selectionIncludingGames = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )
    let result = union(selectionIncludingSocial, selectionIncludingGames)

    #expect(result.categoryTokens.count == 2)
    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
  }

  @Test func fullDifference() async throws {
    let selectionIncludingAll = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverythingWithCategories
    )
    let anotherSelectionIncludingAll = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverything
    )
    let result = difference(selectionIncludingAll, anotherSelectionIncludingAll)

    #expect(result.categoryTokens.count == 0)
    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
  }

  @Test func emptyDifference() async throws {
    let result = difference(
      FamilyActivitySelection(),
      FamilyActivitySelection()
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 0)
  }

  @Test func differenceOfTwoNonOverlapping() async throws {
    let socialSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingSocial
    )
    let gamesSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )
    let result = difference(
      socialSelection,
      gamesSelection
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 1)
  }

  @Test func differenceOfTwoAllAndOne() async throws {
    let everythingSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverything
    )
    let gamesSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )
    let result = difference(
      everythingSelection,
      gamesSelection
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 12)
  }

  @Test func emptySymmetricDifference() async throws {
    let result = symmetricDifference(
      FamilyActivitySelection(),
      FamilyActivitySelection()
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 0)
  }

  @Test func symmetricDifferenceOfTwoNonOverlapping() async throws {
    let socialSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingSocial
    )
    let gamesSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )
    let result = symmetricDifference(
      socialSelection,
      gamesSelection
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 2)
  }

  @Test func symmetricDifferenceOfTwoAllAndOne() async throws {
    let everythingSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingEverything
    )
    let gamesSelection = deserializeFamilyActivitySelection(
      familyActivitySelectionStr: tokenIncludingGames
    )
    let result = symmetricDifference(
      gamesSelection,
      everythingSelection
    )

    #expect(result.applicationTokens.count == 0)
    #expect(result.webDomainTokens.count == 0)
    #expect(result.categoryTokens.count == 12)
  }
}
