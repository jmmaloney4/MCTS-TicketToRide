import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MCTS_TicketToRideTests.allTests),
    ]
}
#endif
