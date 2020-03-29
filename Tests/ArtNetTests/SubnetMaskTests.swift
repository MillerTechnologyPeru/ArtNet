//
//  SubnetMaskTests.swift
//  
//
//  Created by Jorge Loc Rubio on 3/23/20.
//

import Foundation
import XCTest
@testable import ArtNet

final class SubnetMaskTests: XCTestCase {

    static let allTests = [
        ("testBytes", testBytes),
        ("testProperties", testProperties),
        ("testMalformedString", testMalformedString),
        ("testString", testString),
        ("testData", testData),
        ("testMalformedData", testMalformedData)
    ]
    
    func testProperties() {
        
        XCTAssertEqual(SubnetMask.bitWidth, MemoryLayout<SubnetMask.ByteValue>.size * 8)
        XCTAssertEqual(SubnetMask.bitWidth, 32)
        
        XCTAssertEqual(SubnetMask.bits4, SubnetMask(bytes: ( 0xF0, .min, .min, .min)))
        XCTAssertEqual(SubnetMask.bits5, SubnetMask(bytes: ( 0xF8, .min, .min, .min)))
        XCTAssertEqual(SubnetMask.bits6, SubnetMask(bytes: ( 0xFC, .min, .min, .min)))
        XCTAssertEqual(SubnetMask.bits7, SubnetMask(bytes: ( 0xFE, .min, .min, .min)))
        XCTAssertEqual(SubnetMask.classA, SubnetMask(bytes: ( 0xFF, .min, .min, .min)))
        XCTAssertEqual(SubnetMask.bits9, SubnetMask(bytes: ( .max, 0x80, .min, .min)))
        XCTAssertEqual(SubnetMask.bits10, SubnetMask(bytes: ( .max, 0xC0, .min, .min)))
        XCTAssertEqual(SubnetMask.bits11, SubnetMask(bytes: ( .max, 0xE0, .min, .min)))
        XCTAssertEqual(SubnetMask.bits12, SubnetMask(bytes: ( .max, 0xF0, .min, .min)))
        XCTAssertEqual(SubnetMask.bits13, SubnetMask(bytes: ( .max, 0xF8, .min, .min)))
        XCTAssertEqual(SubnetMask.bits14, SubnetMask(bytes: ( .max, 0xFC, .min, .min)))
        XCTAssertEqual(SubnetMask.bits15, SubnetMask(bytes: ( .max, 0xFE, .min, .min)))
        XCTAssertEqual(SubnetMask.classB, SubnetMask(bytes: ( .max, 0xFF, .min, .min)))
        XCTAssertEqual(SubnetMask.bits17, SubnetMask(bytes: ( .max, .max, 0x80, .min)))
        XCTAssertEqual(SubnetMask.bits18, SubnetMask(bytes: ( .max, .max, 0xC0, .min)))
        XCTAssertEqual(SubnetMask.bits19, SubnetMask(bytes: ( .max, .max, 0xE0, .min)))
        XCTAssertEqual(SubnetMask.bits20, SubnetMask(bytes: ( .max, .max, 0xF0, .min)))
        XCTAssertEqual(SubnetMask.bits21, SubnetMask(bytes: ( .max, .max, 0xF8, .min)))
        XCTAssertEqual(SubnetMask.bits22, SubnetMask(bytes: ( .max, .max, 0xFC, .min)))
        XCTAssertEqual(SubnetMask.bits23, SubnetMask(bytes: ( .max, .max, 0xFE, .min)))
        XCTAssertEqual(SubnetMask.classC, SubnetMask(bytes: ( .max, .max, 0xFF, .min)))
        XCTAssertEqual(SubnetMask.bits25, SubnetMask(bytes: ( .max, .max, .max, 0x80)))
        XCTAssertEqual(SubnetMask.bits26, SubnetMask(bytes: ( .max, .max, .max, 0xC0)))
        XCTAssertEqual(SubnetMask.bits27, SubnetMask(bytes: ( .max, .max, .max, 0xE0)))
        XCTAssertEqual(SubnetMask.bits28, SubnetMask(bytes: ( .max, .max, .max, 0xF0)))
        XCTAssertEqual(SubnetMask.bits29, SubnetMask(bytes: ( .max, .max, .max, 0xF8)))
        XCTAssertEqual(SubnetMask.bits30, SubnetMask(bytes: ( .max, .max, .max, 0xFC)))
        
        guard let mask = SubnetMask(rawValue: "250.250.250.0")
            else { XCTFail("Could not parse"); return }
        
        dump(mask)
        
        XCTAssertNotEqual(mask.hashValue, 0)
        XCTAssertEqual(mask.description, "250.250.250.0")
    }
    
    func testBytes() {
        
        let testData: [(rawValue: String, bytes: SubnetMask.ByteValue)] = [
            ("255.255.224.0",   (0xFF, 0xFF, 0xE0, 0x00)),
            ("255.255.255.128", (0xFF, 0xFF, 0xFF, 0x80)),
            ("255.240.0.0",     (0xFF, 0xF0, 0x00, 0x00))
        ]
        
        for test in testData {
            
            guard let address = SubnetMask(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, SubnetMask(bytes: test.bytes))
            
            XCTAssertEqual(address.bytes.0, test.bytes.0)
            XCTAssertEqual(address.bytes.1, test.bytes.1)
            XCTAssertEqual(address.bytes.2, test.bytes.2)
            XCTAssertEqual(address.bytes.3, test.bytes.3)
        }
    }
    
    func testMalformedString() {
        
        let malformed = [
            "0",
            "00",
            "000",
            "0000",
            "0:0:0:0",
            "0,0,0,0",
            "255.0.0.FF",
            "255:255:255:0",
            "256:256:256:256",
            "256.256.256.256"
        ]
        
        malformed.forEach { XCTAssertNil(SubnetMask(rawValue: $0), $0) }
    }
    
    func testString() {
        
        let rawValues = [
            "255.255.224.0",
            "255.255.255.128",
            "255.240.0.0"
        ]
        
        rawValues.forEach { XCTAssertEqual(SubnetMask(rawValue: $0)?.rawValue, $0) }
    }
    
    func testData() {
        
        let testData: [(rawValue: String, data: Data)] = [
            ("255.255.224.0",   Data([0xFF, 0xFF, 0xE0, 0x00])),
            ("255.255.255.128", Data([0xFF, 0xFF, 0xFF, 0x80])),
            ("255.240.0.0",     Data([0xFF, 0xF0, 0x00, 0x00]))
        ]
        
        for test in testData {
            
            guard let address = SubnetMask(rawValue: test.rawValue)
                else { XCTFail("Could not parse"); continue }
            
            XCTAssertEqual(address.rawValue, test.rawValue)
            XCTAssertEqual(address, SubnetMask(data: test.data))
            XCTAssertEqual(address.data, test.data)
        }
    }
    
    func testMalformedData() {
        
        let malformed = [
            Data(),
            Data([0x00]),
            Data([0x00, 0x1A]),
            Data([0x00, 0x1A, 0x7D])
        ]
        
        malformed.forEach { XCTAssertNil(SubnetMask(data: $0)) }
    }
}
