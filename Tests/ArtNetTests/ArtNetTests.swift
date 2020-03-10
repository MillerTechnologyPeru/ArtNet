import XCTest
@testable import ArtNet

final class ArtNetTests: XCTestCase {
    
    static let allTests = [
        ("testID", testID),
        ("testPortAddress", testPortAddress),
        ("testAddress", testAddress)
    ]
    
    func testID() {
        
        let string = "Art-Net"
        let id = ArtNetHeader.ID.artNet
        XCTAssertEqual(id.description, string)
        XCTAssertEqual(id.rawValue, string)
        XCTAssertEqual(id, "Art-Net")
    }
    
    func testPortAddress() {
        
        let portAddress = PortAddress(universe: 1, subnet: 1, net: 1)
        XCTAssertEqual(portAddress, 0x0111)
        XCTAssertNotNil(PortAddress(rawValue: 0x0111))
        XCTAssertEqual(portAddress.universe, 1)
        XCTAssertEqual(portAddress.subnet, 1)
        XCTAssertEqual(portAddress.net, 1)
        XCTAssertNotEqual(portAddress, .zero)
        XCTAssertNotEqual(portAddress, .min)
        XCTAssertNotEqual(portAddress, .max)
        XCTAssertEqual(portAddress.description, "PortAddress(universe: 1, subnet: 1, net: 1)")
        
        XCTAssertNil(PortAddress(rawValue: 0xFFFF))
        XCTAssertNil(PortAddress.Universe(rawValue: 0xF0))
        XCTAssertNil(PortAddress.SubNet(rawValue: 0xF0))
        XCTAssertNil(PortAddress.Net(rawValue: 0xFF))
    }
    
    func testAddress() {
        
        let address = Address(universe: 1, subnet: 1)
        XCTAssertEqual(address, 0x11)
        XCTAssertNotNil(Address(rawValue: 0x11))
        XCTAssertEqual(address.universe, 1)
        XCTAssertEqual(address.subnet, 1)
        XCTAssertEqual(address.description, "Address(universe: 1, subnet: 1)")
    }
}
