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
            
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, Data([
                0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, // Art-Net
                0x00, 0x20,                                     // Opcode: 0x2000
                0x0E, 0x00,                                     // Protocol version: 14
                0x02,                                           // TalkToMe: Diagnostics (0b01)
                0x10])                                          // Diagnostic: Low (0x10)
            )
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
}

extension Sequence where Element == UInt8 {
    
    var hexString: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "0x" + $1.toHexadecimal().uppercased() }) + "]"
    }
}

internal extension UInt8 {
    
    func toHexadecimal() -> String {
        
        var string = String(self, radix: 16)
        if string.count == 1 {
            string = "0" + string
        }
        return string
    }
}
