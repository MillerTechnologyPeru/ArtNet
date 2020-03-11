//
//  RdmUIDTests.swift
//  
//
//  Created by Alsey Coleman Miller on 3/11/20.
//

import Foundation
import XCTest
@testable import ArtNet

final class RdmUIDTests: XCTestCase {
    
    static let allTests = [
        ("testBytes", testBytes),
        ("testProperties", testProperties),
        ("testMalformedString", testMalformedString),
        ("testString", testString),
        ("testData", testData),
        ("testMalformedData", testMalformedData)
    ]
    
    func testProperties() {
        
        XCTAssertEqual(RdmUID.bitWidth, MemoryLayout<RdmUID.ByteValue>.size * 8)
        XCTAssertEqual(RdmUID.bitWidth, 48)
        
        RdmUID.min.data.forEach { XCTAssertEqual($0, .min) }
        RdmUID.max.data.forEach { XCTAssertEqual($0, .max) }
        RdmUID.zero.data.forEach { XCTAssertEqual($0, 0) }
        XCTAssertEqual(RdmUID.zero, RdmUID.min)
        
        guard let address = RdmUID(rawValue: "001A7DDA7113")
            else { XCTFail("Could not parse"); return }
        
        XCTAssertNotEqual(address.hashValue, 0)
        XCTAssertEqual(address.description, "001A7DDA7113")
    }
    
    func testBytes() {
        
        let testData: [(rawValue: String, bytes: RdmUID.ByteValue)] = [
            ("001A7DDA7113", (0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13)),
            ("5980ED81EE35", (0x59, 0x80, 0xED, 0x81, 0xEE, 0x35)),
            ("ACBC32A66742", (0xAC, 0xBC, 0x32, 0xA6, 0x67, 0x42))
        ]
        
        for test in testData {
            
            guard let address = RdmUID(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, RdmUID(bytes: test.bytes))
            
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
            "AABBCCDD$$",
            "AABBCCDD^^",
            "12C:BB:CC:DD:EE",
            "12C:BB:CC:DD:E",
            "FFFF::7D:DA:71:13",
            "00:1A:7D:DA:71:13a",
            "0:1A:7D:DA:71:13",
            "00:1A:7D:DA:71;13"
        ]
        
        malformed.forEach { XCTAssertNil(RdmUID(rawValue: $0), $0) }
    }
    
    func testString() {
        
        let rawValues = [
            "001A7DDA7113",
            "5980ED81EE35",
            "ACBC32A66742"
        ]
        
        rawValues.forEach { XCTAssertEqual(RdmUID(rawValue: $0)?.rawValue, $0) }
    }
    
    func testData() {
        
        let testData: [(rawValue: String, data: Data)] = [
            ("001A7DDA7113", Data([0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13])),
            ("5980ED81EE35", Data([0x59, 0x80, 0xED, 0x81, 0xEE, 0x35])),
            ("ACBC32A66742", Data([0xAC, 0xBC, 0x32, 0xA6, 0x67, 0x42]))
        ]
        
        for test in testData {
            
            guard let address = RdmUID(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, RdmUID(data: test.data))
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
        
        malformed.forEach { XCTAssertNil(RdmUID(data: $0)) }
    }
}
