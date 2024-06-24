//
//  SubnetMask.swift
//  
//
//  Created by Jorge Loc Rubio on 3/23/20.
//

import Foundation

/// Subnet Mask
public struct SubnetMask {
    
    // MARK: - ByteValueType
    
    /// Raw Address 4 bytes (32 bit) value.
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8)
    
    public static var bitWidth: Int { return 32 }
    
    // MARK: - Properties
    
    /// Underlying address bytes (big endian).
    public var bytes: ByteValue
    
    // MARK: - Initialization
    
    /// Initialize with the specifed bytes (in big endian).
    public init(bytes: ByteValue) {
        self.bytes = bytes
    }
}

// Network Bits
public extension SubnetMask {
     
    /// Network Bits 4 - prefix `/4`
    static var bits4: SubnetMask { return SubnetMask(bytes: (0b11110000, .min, .min, .min)) }
    
    /// Network Bits 5 - prefix `/5`
    static var bits5: SubnetMask { return SubnetMask(bytes: (0b11111000, .min, .min, .min)) }
    
    /// Network Bits 6 - prefix `/6`
    static var bits6: SubnetMask { return SubnetMask(bytes: (0b11111100, .min, .min, .min)) }
    
    /// Network Bits 7 - prefix `/7`
    static var bits7: SubnetMask { return SubnetMask(bytes: (0b11111110, .min, .min, .min)) }
    
    /// Network Bits 8 - prefix `/8`
    static var classA: SubnetMask { return SubnetMask(bytes: (.max, .min, .min, .min)) }
    
    /// Network Bits 9 - prefix `/9`
    static var bits9: SubnetMask  { return SubnetMask(bytes: (.max, 0b10000000, .min, .min)) }
    
    /// Network Bits 10 - prefix `/10`
    static var bits10: SubnetMask { return SubnetMask(bytes: (.max, 0b11000000, .min, .min)) }
    
    /// Network Bits 11 - prefix `/11`
    static var bits11: SubnetMask { return SubnetMask(bytes: (.max, 0b11100000, .min, .min)) }
    
    /// Network Bits 12 - prefix `/12`
    static var bits12: SubnetMask { return SubnetMask(bytes: (.max, 0b11110000, .min, .min)) }
    
    /// Network Bits 13 - prefix `/13`
    static var bits13: SubnetMask { return SubnetMask(bytes: (.max, 0b11111000, .min, .min)) }
    
    /// Network Bits 14 - prefix `/14`
    static var bits14: SubnetMask { return SubnetMask(bytes: (.max, 0b11111100, .min, .min)) }
    
    /// Network Bits 15 - prefix `/15`
    static var bits15: SubnetMask { return SubnetMask(bytes: (.max, 0b11111110, .min, .min)) }
    
    /// Network Bits 16 - prefix `/16`
    static var classB: SubnetMask { return SubnetMask(bytes: (.max, .max, .min, .min)) }
    
    /// Network Bits 17 - prefix `/17`
    static var bits17: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b10000000, .min)) }
    
    /// Network Bits 18 - prefix `/18`
    static var bits18: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11000000, .min)) }
    
    /// Network Bits 19 - prefix `/19`
    static var bits19: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11100000, .min)) }
    
    /// Network Bits 20 - prefix `/20`
    static var bits20: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11110000, .min)) }
    
    /// Network Bits 21 - prefix `/21`
    static var bits21: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11111000, .min)) }
    
    /// Network Bits 22 - prefix `/22`
    static var bits22: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11111100, .min)) }
    
    /// Network Bits 23 - prefix `/23`
    static var bits23: SubnetMask { return SubnetMask(bytes: (.max, .max, 0b11111110, .min)) }
    
    /// Network Bits 24 - prefix `/24`
    static var classC: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, .min)) }
    
    /// Network Bits 25 - prefix `/25`
    static var bits25: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b10000000)) }
    
    /// Network Bits 26 - prefix `/26`
    static var bits26: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b11000000)) }
    
    /// Network Bits 27 - prefix `/27`
    static var bits27: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b11100000)) }
    
    /// Network Bits 28 - prefix `/28`
    static var bits28: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b11110000)) }
    
    /// Network Bits 29 - prefix `/29`
    static var bits29: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b11111000)) }
    
    /// Network Bits 30 - prefix `/30`
    static var bits30: SubnetMask { return SubnetMask(bytes: (.max, .max, .max, 0b11111100)) }
}

// MARK: - Data

public extension SubnetMask {
    
    static var length: Int { return 4 }
    
    init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        self.bytes = (data[0], data[1], data[2], data[3])
    }
    
    var data: Data {
        return Data(self)
    }
}

// MARK: - RawRepresentable

extension SubnetMask: RawRepresentable {
    
    /// Initialize a Subnet Mask  from its big endian string representation (e.g. `255.255.255.0`).
    public init?(rawValue: String) {
        
        var bytes: ByteValue = (0, 0, 0, 0)
        
        let components = rawValue.components(separatedBy: ".")
        
        guard components.count == 4
            else { return nil }
        
        for (index, string) in components.enumerated() {
            
            guard let int = Int(string)
                else { return nil }
            
            let hex = String(int, radix: 16)
            
            guard let byte = UInt8(hex, radix: 16)
                else { return nil }
            
            withUnsafeMutablePointer(to: &bytes) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 4) {
                    $0.advanced(by: index).pointee = byte
                }
            }
        }
        
        self.init(bytes: bytes)
    }
    
    /// Convert a Subnet Mask to its big endian string representation (e.g. `255.255.255.0`).
    public var rawValue: String {
        return bytes.0.description
            + "."
            + bytes.1.description
            + "."
            + bytes.2.description
            + "."
            + bytes.3.description
    }
}

// MARK: - Equatable

extension SubnetMask: Equatable {
    
    public static func == (lhs: SubnetMask, rhs: SubnetMask) -> Bool {
        return lhs.bytes.0 == rhs.bytes.0
            && lhs.bytes.1 == rhs.bytes.1
            && lhs.bytes.2 == rhs.bytes.2
            && lhs.bytes.3 == rhs.bytes.3
    }
}

// MARK: - Hashable

extension SubnetMask: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        bytes.0.hash(into: &hasher)
        bytes.1.hash(into: &hasher)
        bytes.2.hash(into: &hasher)
        bytes.3.hash(into: &hasher)
    }
}

// MARK: - CustomStringConvertible

extension SubnetMask: CustomStringConvertible {
    
    public var description: String { return rawValue }
}

// MARK: Sequence

extension SubnetMask: Sequence {
    
    public typealias Element = UInt8
    
    public func makeIterator() -> IndexingIterator<Self> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: RandomAccessCollection

extension SubnetMask: RandomAccessCollection {
    
    public var count: Int {
        return SubnetMask.length
    }
    
    public subscript (index: Int) -> UInt8 {
        switch index {
        case 0: return bytes.0
        case 1: return bytes.1
        case 2: return bytes.2
        case 3: return bytes.3
        default: fatalError("Invalid index \(index)")
        }
    }
    
    /// The start `Index`.
    public var startIndex: Int {
        return 0
    }
    
    /// The end `Index`.
    ///
    /// This is the "one-past-the-end" position, and will always be equal to the `count`.
    public var endIndex: Int {
        return count
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}

// MARK: - Codable

extension SubnetMask: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = Self.init(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid \(Self.self) string \(rawValue)")
        }
        self = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - ArtNet Codable

extension SubnetMask: ArtNetCodable {
    
    public init?(artNet data: Data) {
        self.init(data: data)
    }
    
    public var artNet: Data {
        return data
    }
    
    public static var artNetLength: Int { return length }
}
