import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArtNetTests.allTests),
        testCase(OEMTests.allTests),
        testCase(PacketTests.allTests),
    ]
}
#endif
