import XCTest
@testable import ArtNet

final class ArtNetTests: XCTestCase {
    
    static let allTests = [
        ("testPoll", testPoll),
    ]
    
    func testID() {
        
        let string = "Art-Net"
        let id = ArtNetHeader.ID.artNet
        XCTAssertEqual(id.description, string)
        XCTAssertEqual(id.rawValue, string)
        XCTAssertEqual(id, "Art-Net")
        XCTAssertEqual(id.data, Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00]))
        XCTAssertEqual(id, ArtNetHeader.ID(data: id.data))
    }
    
    func testPoll() {
        
        let poll = ArtPoll(
            behavior: [.diagnostics],
            priority: .low
        )
        
        XCTAssertEqual(poll.protocolVersion, .current)
    }
}
