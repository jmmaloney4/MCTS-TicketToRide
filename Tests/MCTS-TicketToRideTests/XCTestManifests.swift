import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(MCTS_TicketToRideTests.allTests),
        ]
    }
#endif
