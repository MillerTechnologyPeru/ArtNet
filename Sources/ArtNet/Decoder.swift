//
//  Decoder.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

/// Art-Net Packet Decoder
public struct ArtNetDecoder {
    
    // MARK: - Properties
    
    /// Any contextual information set by the user for encoding.
    public var userInfo = [CodingUserInfoKey : Any]()
    
    /// Logger handler
    public var log: ((String) -> ())?
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - Methods
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable, T: ArtNetPacket {
        
        log?("Will decode \(T.opCode) packet")
        
        guard data.count > 10 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Insufficient bytes (\(data.count))"))
        }
        
        var decoder = Decoder(
            userInfo: userInfo,
            log: log,
            formatting: ArtNetHeader.formatting,
            data: data.subdataNoCopy(in: 0 ..< 10)
        )
        
        let header = try ArtNetHeader.init(from: decoder)
        
        guard header.id == .artNet else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid ID \(header.id)"))
        }
        
        guard header.opCode == T.opCode else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Found opcode \(header.opCode) but expected \(T.opCode)"))
        }
        
        decoder = Decoder(
            userInfo: userInfo,
            log: log,
            formatting: T.formatting,
            data: data.suffixNoCopy(from: 10)
        )
        
        // decode from container
        return try T.init(from: decoder)
    }
}

// MARK: - Decoder

internal extension ArtNetDecoder {
    
    final class Decoder: Swift.Decoder {
        
        /// The path of coding keys taken to get to this point in decoding.
        fileprivate(set) var codingPath: [CodingKey]
        
        /// Any contextual information set by the user for decoding.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// Logger
        let log: ((String) -> ())?
        
        public let data: Data
        
        public fileprivate(set) var offset: Int = 0
        
        public let formatting: ArtNetFormatting
        
        // MARK: - Initialization
        
        fileprivate init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: ((String) -> ())?,
             formatting: ArtNetFormatting,
             data: Data) {
            
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
            self.formatting = formatting
            self.data = data
        }
        
        // MARK: - Methods
        
        func container <Key: CodingKey> (keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
            
            log?("Requested container keyed by \(type.sanitizedName) for path \"\(codingPath.path)\"")
            
            fatalError()
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPath.path)\"")
            
            fatalError()
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            
            log?("Requested single value container for path \"\(codingPath.path)\"")
            
            fatalError()
        }
    }
}

// MARK: - Unboxing Values

internal extension ArtNetDecoder.Decoder {
    
    func read(_ bytes: Int) throws -> Data {
        let start = offset
        let end = offset + bytes
        guard self.data.count >= end else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Insufficient bytes (\(data.count)), expected \(end) bytes"))
        }
        offset = end // new offset
        return self.data.subdataNoCopy(in: start ..< end)
    }
    
    func read <T: ArtNetRawDecodable> (_ type: T.Type) throws -> T {
        
        let offset = self.offset
        let data = try read(T.binaryLength)
        guard let value = T.init(binaryData: data) else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Could not parse \(type) from \(data) at offset \(offset)"))
        }
        
        return value
    }
    
    func readString() throws -> String {
        
        let offset = self.offset
        let key = self.codingPath.last
        let encoding = key.flatMap { formatting.string[.init($0)] } ?? .variableLength
        let length: Int
        // get string indices in data
        switch encoding {
        case .variableLength:
            guard let end = self.data.suffixNoCopy(from: offset)
                .firstIndex(of: 0x00)
                else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing null terminator for string starting at offset \(offset)"))
            }
            length = end - offset
        case let .fixedLength(fixedLength):
            length = fixedLength
        }
        // read data and parse string
        let data = try read(length)
        guard let string = data.withUnsafeBytes({
            $0.baseAddress.flatMap { String(validatingUTF8: $0.assumingMemoryBound(to: CChar.self)) }
        }) else {
            let invalidString = data.withUnsafeBytes({
                $0.baseAddress.flatMap { String(cString: $0.assumingMemoryBound(to: CChar.self)) } ?? ""
            })
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid string \"\(invalidString)\" at offset \(offset)"))
        }
        return string
    }
    
    func readNumeric <T: ArtNetRawDecodable & FixedWidthInteger> (_ type: T.Type) throws -> T {
        
        let key = self.codingPath.last
        let isLittleEndian = key.flatMap { formatting.littleEndian.contains(.init($0)) } ?? false
        var value = try read(type)
        value = isLittleEndian ? T.init(littleEndian: value) : T.init(bigEndian: value)
        return value
    }
    
    func readDouble(_ data: Data) throws -> Double {
        let bitPattern = try readNumeric(UInt64.self)
        return Double(bitPattern: bitPattern)
    }
    
    func readFloat(_ data: Data) throws -> Float {
        let bitPattern = try readNumeric(UInt32.self)
        return Float(bitPattern: bitPattern)
    }
    
    /// Attempt to decode native value to expected type.
    func readDecodable <T: Decodable> (_ type: T.Type) throws -> T {
                
        // override for native types
        if type == Data.self {
            return readData() as! T // In this case T is Data
        } else if let decodableType = type as? ArtNetCodable.Type {
            return try readArtNetDecodable(decodableType) as! T
        } else {
            // decode using Decodable, container should read directly.
            return try T(from: self)
        }
    }
}

private extension ArtNetDecoder.Decoder {
    
    func readArtNetDecodable(_ type: ArtNetDecodable.Type) throws -> ArtNetDecodable {
        
        let offset = self.offset
        let data = try read(type.length)
        guard let value = type.init(artNet: data) else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Could not parse \(String(reflecting: type)) from \(data) at offset \(offset)"))
        }
        return value
    }
    
    func readData() throws -> Data {
        
        let offset = self.offset
        
    }
}

// MARK: - Decodable Types

/// Private protocol for decoding TLV values into raw data.
internal protocol ArtNetRawDecodable {
    
    init?(binaryData data: Data)
    
    static var binaryLength: Int { get }
}

extension Bool: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == Bool.binaryLength
            else { return nil }
        
        self = data[0] != 0
    }
    
    public static var binaryLength: Int { return MemoryLayout<UInt8>.size }
}

extension UInt8: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<UInt8>.size
            else { return nil }
        
        self = data[0]
    }
    
    public static var binaryLength: Int { return MemoryLayout<UInt8>.size }
}

extension UInt16: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<UInt16>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<UInt16>.size }
}

extension UInt32: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<UInt32>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<UInt32>.size }
}

extension UInt64: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<UInt64>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<UInt64>.size }
}

extension Int8: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<Int8>.size
            else { return nil }
        
        self = Int8(bitPattern: data[0])
    }
    
    public static var binaryLength: Int { return MemoryLayout<Int8>.size }
}

extension Int16: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<Int16>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<Int16>.size }
}

extension Int32: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<Int32>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<Int32>.size }
}

extension Int64: ArtNetRawDecodable {
    
    public init?(binaryData data: Data) {
        
        guard data.count == MemoryLayout<Int64>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]))
    }
    
    public static var binaryLength: Int { return MemoryLayout<Int64>.size }
}
