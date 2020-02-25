//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/22/20.
//

import Foundation

/// Mac Address.
public struct MacAddress {
    
    // MARK: - ByteValueType
    
    /// Raw Address 6 bytes (48 bit) value.
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public static var bitWidth: Int { return 48 }
    
    // MARK: - Properties
    
    /// Underlying address bytes (big endian).
    public var bytes: ByteValue
    
    // MARK: - Initialization
    
    /// Initialize with the specifed bytes (in big endian).
    public init(bytes: ByteValue) {
        self.bytes = bytes
    }
}

public extension MacAddress {
    
    /// The minimum representable value in this type.
    static var min: MacAddress { return MacAddress(bytes: (.min, .min, .min, .min, .min, .min)) }
    
    /// The maximum representable value in this type.
    static var max: MacAddress { return MacAddress(bytes: (.max, .max, .max, .max, .max, .max)) }
    
    /// A zero address.
    static var zero: MacAddress { return .min }
}

// MARK: - Data

public extension MacAddress {
    
    static var length: Int { return 6 }
    
    init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        self.bytes = (data[0], data[1], data[2], data[3], data[4], data[5])
    }
    
    var data: Data {
        return Data(self)
    }
}

// MARK: - RawRepresentable

extension MacAddress: RawRepresentable {
    
    /// Initialize a Mac dddress from its big endian string representation (e.g. `00:1A:7D:DA:71:13`).
    public init?(rawValue: String) {
        
        // verify string length
        guard rawValue.utf8.count == 17
            else { return nil }
        
        var bytes: ByteValue = (0, 0, 0, 0, 0, 0)
        
        let components = rawValue.components(separatedBy: ":")
        
        guard components.count == 6
            else { return nil }
        
        for (index, string) in components.enumerated() {
            
            guard let byte = UInt8(string, radix: 16)
                else { return nil }
            
            withUnsafeMutablePointer(to: &bytes) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 6) {
                    $0.advanced(by: index).pointee = byte
                }
            }
        }
        
        self.init(bytes: bytes)
    }
    
    /// Convert a Mac dddress to its big endian string representation (e.g. `00:1A:7D:DA:71:13`).
    public var rawValue: String {
        return String(format: "%02X:%02X:%02X:%02X:%02X:%02X", bytes.0, bytes.1, bytes.2, bytes.3, bytes.4, bytes.5)
    }
}

// MARK: - Equatable

extension MacAddress: Equatable {
    
    public static func == (lhs: MacAddress, rhs: MacAddress) -> Bool {
        return lhs.bytes.0 == rhs.bytes.0
            && lhs.bytes.1 == rhs.bytes.1
            && lhs.bytes.2 == rhs.bytes.2
            && lhs.bytes.3 == rhs.bytes.3
            && lhs.bytes.4 == rhs.bytes.4
            && lhs.bytes.5 == rhs.bytes.5
    }
}

// MARK: - Hashable

extension MacAddress: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        bytes.0.hash(into: &hasher)
        bytes.1.hash(into: &hasher)
        bytes.2.hash(into: &hasher)
        bytes.3.hash(into: &hasher)
        bytes.4.hash(into: &hasher)
        bytes.5.hash(into: &hasher)
    }
}

// MARK: - CustomStringConvertible

extension MacAddress: CustomStringConvertible {
    
    public var description: String { return rawValue }
}

// MARK: Sequence

extension MacAddress: Sequence {
    
    public func makeIterator() -> IndexingIterator<Self> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: RandomAccessCollection

extension MacAddress: RandomAccessCollection {
    
    public var count: Int {
        return MacAddress.length
    }
    
    public subscript (index: Int) -> UInt8 {
        switch index {
        case 0: return bytes.0
        case 1: return bytes.1
        case 2: return bytes.2
        case 3: return bytes.3
        case 4: return bytes.4
        case 5: return bytes.5
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

extension MacAddress: Codable {
    
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

extension MacAddress: ArtNetCodable {
    
    public init?(artNet data: Data) {
        self.init(data: data)
    }
    
    public var artNet: Data {
        return data
    }
    
    public static var artNetLength: Int { return length }
}
