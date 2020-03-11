//
//  MacAddressTests.swift
//  
//
//  Created by Alsey Coleman Miller on 3/11/20.
//

import Foundation
import XCTest
@testable import ArtNet

final class MacAddressTests: XCTestCase {
    
    static let allTests = [
        ("testBytes", testBytes),
        ("testProperties", testProperties),
        ("testMalformedString", testMalformedString),
        ("testString", testString),
        ("testData", testData),
        ("testMalformedData", testMalformedData)
    ]
    
    func testProperties() {
        
        XCTAssertEqual(MacAddress.bitWidth, MemoryLayout<MacAddress.ByteValue>.size * 8)
        XCTAssertEqual(MacAddress.bitWidth, 48)
        
        MacAddress.min.data.forEach { XCTAssertEqual($0, .min) }
        MacAddress.max.data.forEach { XCTAssertEqual($0, .max) }
        MacAddress.zero.data.forEach { XCTAssertEqual($0, 0) }
        XCTAssertEqual(MacAddress.zero, MacAddress.min)
        
        guard let address = MacAddress(rawValue: "00:1A:7D:DA:71:13")
            else { XCTFail("Could not parse"); return }
        
        XCTAssertNotEqual(address.hashValue, 0)
        XCTAssertEqual(address.description, "00:1A:7D:DA:71:13")
    }
    
    func testBytes() {
        
        let testData: [(rawValue: String, bytes: MacAddress.ByteValue)] = [
            ("00:1A:7D:DA:71:13", (0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13)),
            ("59:80:ED:81:EE:35", (0x59, 0x80, 0xED, 0x81, 0xEE, 0x35)),
            ("AC:BC:32:A6:67:42", (0xAC, 0xBC, 0x32, 0xA6, 0x67, 0x42))
        ]
        
        for test in testData {
            
            guard let address = MacAddress(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, MacAddress(bytes: test.bytes))
            
            XCTAssertEqual(address.bytes.0, test.bytes.0)
            XCTAssertEqual(address.bytes.1, test.bytes.1)
            XCTAssertEqual(address.bytes.2, test.bytes.2)
            XCTAssertEqual(address.bytes.3, test.bytes.3)
            XCTAssertEqual(address.bytes.4, test.bytes.4)
            XCTAssertEqual(address.bytes.5, test.bytes.5)
        }
    }
    
    func testMalformedString() {
        
        let malformed = [
            "0",
            "01",
            "012",
            "xxxx",
            "xxxxx",
            "0xxxxx",
            "0123456",
            "012g4567",
            "012345678",
            "0x234567u9",
            "01234567890",
            "@aXX:XX:XX:XX:&&",
            "AA:BB:CC:DD:$$",
            "AA:BB:CC:DD:^^",
            "12C:BB:CC:DD:EE",
            "12C:BB:CC:DD:E",
            "FFFF::7D:DA:71:13",
            "00:1A:7D:DA:71:13a",
            "0:1A:7D:DA:71:13",
            "00:1A:7D:DA:71;13"
        ]
        
        malformed.forEach { XCTAssertNil(MacAddress(rawValue: $0), $0) }
    }
    
    func testString() {
        
        let rawValues = [
            "00:1A:7D:DA:71:13",
            "59:80:ED:81:EE:35",
            "AC:BC:32:A6:67:42"
        ]
        
        rawValues.forEach { XCTAssertEqual(MacAddress(rawValue: $0)?.rawValue, $0) }
    }
    
    func testData() {
        
        let testData: [(rawValue: String, data: Data)] = [
            ("00:1A:7D:DA:71:13", Data([0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13])),
            ("59:80:ED:81:EE:35", Data([0x59, 0x80, 0xED, 0x81, 0xEE, 0x35])),
            ("AC:BC:32:A6:67:42", Data([0xAC, 0xBC, 0x32, 0xA6, 0x67, 0x42]))
        ]
        
        for test in testData {
            
            guard let address = MacAddress(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, MacAddress(data: test.data))
            XCTAssertEqual(address.data, test.data)
        }
    }
    
    func testMalformedData() {
        
        let malformed = [
            Data(),
            Data([0x00]),
            Data([0x00, 0x1A]),
            Data([0x00, 0x1A, 0x7D]),
            Data([0x00, 0x1A, 0x7D, 0xDA]),
            Data([0x00, 0x1A, 0x7D, 0xDA, 0x71]),
            Data([0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13, 0xAA])
        ]
        
        malformed.forEach { XCTAssertNil(MacAddress(data: $0)) }
    }
}
