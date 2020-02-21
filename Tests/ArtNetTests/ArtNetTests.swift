import XCTest
@testable import ArtNet

final class ArtNetTests: XCTestCase {
    
    static let allTests = [
        ("testPoll", testPoll),
    ]
    
    func testPoll() {
        
        let poll = ArtPoll(
            behavior: [.diagnostics],
            priority: [.low]
        )
        
        
    }
}
