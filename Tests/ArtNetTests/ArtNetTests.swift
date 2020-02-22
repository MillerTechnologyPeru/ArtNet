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
        
        do {
            let value = ArtPoll(
                behavior: [.diagnostics],
                priority: .low
            )
            
            XCTAssertEqual(value.protocolVersion, .current)
            
            var encoder = ArtNetEncoder()
            encoder.log = { print("Encoder:", $0) }
            let encodedData = try encoder.encode(value)
            
            print("[" + encodedData.reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "0x" + String($1, radix: 16).uppercased() }) + "]")
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x0E, 0x00, 0x02, 0x10]))
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
}
