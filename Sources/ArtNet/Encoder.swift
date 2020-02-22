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
    
    public func encode<T>(_ value: T) throws -> Data where T: Encodable, T: ArtNetPacket {
        
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
        
        fileprivate init(codingPath: [CodingKey] = [],
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
    
    func boxString(_ value: String) -> Data {
        
        let key = self.codingPath.last
        let encoding = key.flatMap { formatting.string[.init($0)] } ?? .variableLength
        switch encoding {
        case .variableLength:
            return Data(unsafeBitCast(value.utf8CString, to: ContiguousArray<UInt8>.self))
        case let .fixedLength(length):
            let stringLength = max(length - 1, 0)
            var data = Data(repeating: 0x00, count: length)
            value.utf8
                .prefix(stringLength)
                .enumerated()
                .forEach { data[$0.offset] = $0.element }
            return data
        }
    }
    
    @inline(__always)
    func boxNumeric <T: ArtNetRawEncodable & FixedWidthInteger> (_ value: T) -> Data {
        
        let key = self.codingPath.last
        let isLittleEndian = key.flatMap { formatting.littleEndian.contains(.init($0)) } ?? false
        let numericValue = isLittleEndian ? value.littleEndian : value.bigEndian
        return box(numericValue)
    }
    
    @inline(__always)
    func boxDouble(_ double: Double) -> Data {
        return boxNumeric(double.bitPattern)
    }
    
    @inline(__always)
    func boxFloat(_ float: Float) -> Data {
        return boxNumeric(float.bitPattern)
    }
    
    func writeEncodable <T: Encodable> (_ value: T) throws {
        
        if let data = value as? Data {
            write(boxData(data))
        } else if let encodable = value as? ArtNetEncodable {
            write(encodable.artNet)
        } else {
            // encode using Encodable, container should write directly.
            try value.encode(to: self)
        }
    }
}

private extension ArtNetEncoder.Encoder {
    
    func boxData(_ data: Data) -> Data {
        
        let key = self.codingPath.last
        let dataFormatting = key.flatMap { formatting.data[.init($0)] } ?? .lengthSpecifier
        
        switch dataFormatting {
        case .lengthSpecifier:
            var encodedData = Data(capacity: 2 + data.count)
            let length = UInt16(data.count)
            encodedData.append(length.binaryData)
            encodedData.append(data)
            return encodedData
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
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = encoder.boxString(value)
        try setValue(value, data: data, for: key)
    }
    
    func encode <T: Encodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        encoder.log?("Will encode value for key \(key.stringValue) at path \"\(encoder.codingPath.path)\"")
        try encoder.writeEncodable(value)
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
        let data = encoder.boxNumeric(value)
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

// MARK: - SingleValueEncodingContainer

internal final class ArtNetSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: ArtNetEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    /// Whether the data has been written
    private var didWrite = false
    
    // MARK: - Initialization
    
    init(referencing encoder: ArtNetEncoder.Encoder) {
        
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }
    
    // MARK: - Methods
    
    func encodeNil() throws {
        // do nothing
    }
    
    func encode(_ value: Bool) throws { write(encoder.box(value)) }
    
    func encode(_ value: String) throws { write(encoder.boxString(value)) }
    
    func encode(_ value: Double) throws { write(encoder.boxDouble(value)) }
    
    func encode(_ value: Float) throws { write(encoder.boxFloat(value)) }
    
    func encode(_ value: Int) throws { write(encoder.boxNumeric(Int32(value))) }
    
    func encode(_ value: Int8) throws { write(encoder.box(value)) }
    
    func encode(_ value: Int16) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int32) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int64) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt) throws { write(encoder.boxNumeric(UInt32(value))) }
    
    func encode(_ value: UInt8) throws { write(encoder.box(value)) }
    
    func encode(_ value: UInt16) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt32) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt64) throws { write(encoder.boxNumeric(value)) }
    
    func encode <T: Encodable> (_ value: T) throws {
        precondition(didWrite == false, "Data already written")
        try encoder.writeEncodable(value)
        self.didWrite = true
    }
    
    // MARK: - Private Methods
    
    private func write(_ data: Data) {
        
        precondition(didWrite == false, "Data already written")
        self.encoder.write(data)
        self.didWrite = true
    }
}

// MARK: - UnkeyedEncodingContainer

internal final class ArtNetUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
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
    
    /// The number of elements encoded into the container.
    private(set) var count: Int = 0
    
    func encodeNil() throws {
        // do nothing
    }
    
    func encode(_ value: Bool) throws { append(encoder.box(value)) }
    
    func encode(_ value: String) throws { append(encoder.boxString(value)) }
    
    func encode(_ value: Double) throws { append(encoder.boxNumeric(value.bitPattern)) }
    
    func encode(_ value: Float) throws { append(encoder.boxNumeric(value.bitPattern)) }
    
    func encode(_ value: Int) throws { append(encoder.boxNumeric(Int32(value))) }
    
    func encode(_ value: Int8) throws { append(encoder.box(value)) }
    
    func encode(_ value: Int16) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int32) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int64) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt) throws { append(encoder.boxNumeric(UInt32(value))) }
    
    func encode(_ value: UInt8) throws { append(encoder.box(value)) }
    
    func encode(_ value: UInt16) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt32) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt64) throws { append(encoder.boxNumeric(value)) }
    
    func encode <T: Encodable> (_ value: T) throws {
        try encoder.writeEncodable(value)
        count += 1
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        fatalError()
    }
    
    // MARK: - Private Methods
    
    private func append(_ data: Data) {
        self.encoder.write(data)
        count += 1
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
