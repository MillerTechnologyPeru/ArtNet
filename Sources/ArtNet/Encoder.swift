//
//  Encoder.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

/// ArtNet Packet Encoder
public struct ArtNetEncoder {
    
    // MARK: - Properties
    
    /// Any contextual information set by the user for encoding.
    public var userInfo = [CodingUserInfoKey : Any]()
    
    /// Logging handler
    public var log: ((String) -> ())?
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - Methods
    
    public func encode <T> (_ value: T) throws -> Data where T: Encodable, T: ArtNetPacket {
        
        log?("Will encode \(T.opCode) packet")
        
        let encoder = Encoder(
            userInfo: userInfo,
            log: log,
            formatting: ArtNetHeader.formatting,
            data: Data(capacity: 10 + MemoryLayout<T>.size(ofValue: value))
        )
        
        // encode header
        let header = ArtNetHeader(id: .artNet, opCode: T.opCode)
        try header.encode(to: encoder)
        
        // encode packet
        encoder.formatting = T.formatting
        try value.encode(to: encoder)
        
        return encoder.data
    }
}

// MARK: - Encoder

internal extension ArtNetEncoder {
    
    final class Encoder: Swift.Encoder {
        
        // MARK: - Properties
        
        /// The path of coding keys taken to get to this point in encoding.
        fileprivate(set) var codingPath: [CodingKey]
        
        /// Any contextual information set by the user for encoding.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// Logger
        let log: ((String) -> ())?
        
        /// Output formatting
        fileprivate(set) var formatting: ArtNetFormatting
        
        /// Output Data
        private(set) var data: Data
        
        // MARK: - Initialization
        
        init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: ((String) -> ())?,
             formatting: ArtNetFormatting,
             data: Data = Data()) {
            
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
            self.formatting = formatting
            self.data = data
        }
        
        // MARK: - Encoder
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            
            log?("Requested container keyed by \(type.sanitizedName) for path \"\(codingPath.path)\"")
            let keyedContainer = ArtNetKeyedContainer<Key>(referencing: self)
            return KeyedEncodingContainer(keyedContainer)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPath.path)\"")
            return ArtNetUnkeyedEncodingContainer(referencing: self)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            log?("Requested single value container for path \"\(codingPath.path)\"")
            return ArtNetSingleValueEncodingContainer(referencing: self)
        }
    }
}

internal extension ArtNetEncoder.Encoder {
    
    func write(_ data: Data) {
        self.data.append(data)
    }
    
    @inline(__always)
    func box <T: ArtNetRawEncodable> (_ value: T) -> Data {
        return value.binaryData
    }
    
    @inline(__always)
    func boxNumeric <T: ArtNetRawEncodable & FixedWidthInteger, K: CodingKey> (_ value: T, for key: K) -> Data {
        
        let isLittleEndian = formatting.littleEndian.contains(.init(key))
        let numericValue = isLittleEndian ? value.littleEndian : value.bigEndian
        return box(numericValue)
    }
    
    @inline(__always)
    func boxDouble <K: CodingKey> (_ double: Double, for key: K) -> Data {
        return boxNumeric(double.bitPattern, for: key)
    }
    
    @inline(__always)
    func boxFloat <K: CodingKey> (_ float: Float, for key: K) -> Data {
        return boxNumeric(float.bitPattern, for: key)
    }
    
    func writeEncodable <T: Encodable, K: CodingKey> (_ value: T, for key: K) throws {
        
        if let data = value as? Data {
            write(boxData(data, for: key))
        } else if let encodable = value as? ArtNetEncodable {
            write(encodable.artNet)
        } else {
            // encode using Encodable, container should write directly.
            try value.encode(to: self)
        }
    }
}

private extension ArtNetEncoder.Encoder {
    
    func boxData <K: CodingKey> (_ data: Data, for key: K) -> Data {
        
        let dataFormatting = formatting.data[.init(key)] ?? .lengthSpecifier
        
        switch dataFormatting {
        case .lengthSpecifier:
            var data = Data(capacity: 2 + data.count)
            let length = UInt16(data.count)
            data.append(length.binaryData)
            data.append(data)
        case .remainder:
            return data
        }
    }
}


// MARK: - KeyedEncodingContainerProtocol

internal struct ArtNetKeyedContainer <K : CodingKey> : KeyedEncodingContainerProtocol {
    
    typealias Key = K
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: ArtNetEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    init(referencing encoder: ArtNetEncoder.Encoder) {
        
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }
    
    // MARK: - Methods
    
    func encodeNil(forKey key: K) throws {
        // do nothing
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        try encodeArtNet(value, forKey: key)
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        try encodeNumeric(Int32(value), forKey: key)
    }
    
    func encode(_ value: Int8, forKey key: K) throws {
        try encodeArtNet(value, forKey: key)
    }
    
    func encode(_ value: Int16, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Int32, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Int64, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt, forKey key: K) throws {
        try encodeNumeric(UInt32(value), forKey: key)
    }
    
    func encode(_ value: UInt8, forKey key: K) throws {
        try encodeArtNet(value, forKey: key)
    }
    
    func encode(_ value: UInt16, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt32, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt64, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Float, forKey key: K) throws {
        try encodeNumeric(value.bitPattern, forKey: key)
    }
    
    func encode(_ value: Double, forKey key: K) throws {
        try encodeNumeric(value.bitPattern, forKey: key)
    }
    
    func encode(_ value: String, forKey key: K) throws {
        try encodeArtNet(value, forKey: key)
    }
    
    func encode <T: Encodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        encoder.log?("Will encode value for key \(key.stringValue) at path \"\(encoder.codingPath.path)\"")
        try encoder.writeEncodable(value, for: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        fatalError()
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        
        fatalError()
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        
        fatalError()
    }
    
    // MARK: - Private Methods
    
    private func encodeNumeric <T: ArtNetRawEncodable & FixedWidthInteger> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = encoder.boxNumeric(value, for: key)
        try setValue(value, data: data, for: key)
    }
    
    private func encodeArtNet <T: ArtNetRawEncodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = encoder.box(value)
        try setValue(value, data: data, for: key)
    }
    
    private func setValue <T> (_ value: T, data: Data, for key: Key) throws {
        encoder.log?("Will encode value for key \(key.stringValue) at path \"\(encoder.codingPath.path)\"")
        self.encoder.write(data)
    }
}

// MARK: - Data Types

/// Private protocol for encoding Art-Net values into raw data.
internal protocol ArtNetRawEncodable {
    
    var binaryData: Data { get }
}

internal extension ArtNetRawEncodable {
    
    var copyingBytes: Data {
        return withUnsafePointer(to: self, { Data(bytes: $0, count: MemoryLayout<Self>.size) })
    }
}

extension UInt8: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension UInt16: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension UInt32: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension UInt64: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension Int8: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension Int16: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension Int32: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension Int64: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return copyingBytes
    }
}

extension Float: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return bitPattern.copyingBytes
    }
}

extension Double: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return bitPattern.copyingBytes
    }
}

extension Bool: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return UInt8(self ? 1 : 0).copyingBytes
    }
}

extension String: ArtNetRawEncodable {
    
    public var binaryData: Data {
        return Data(unsafeBitCast(self.utf8CString, to: ContiguousArray<UInt8>.self))
    }
}
