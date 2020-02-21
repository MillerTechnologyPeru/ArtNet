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
            let keyedContainer = ArtNetKeyedContainer<Key>(referencing: self, wrapping: stackContainer)
            return KeyedEncodingContainer(keyedContainer)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPath.path)\"")
            return ArtNetUnkeyedEncodingContainer(referencing: self, wrapping: stackContainer)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            log?("Requested single value container for path \"\(codingPath.path)\"")
            return ArtNetSingleValueEncodingContainer(referencing: self, wrapping: stackContainer)
        }
    }
}

internal extension ArtNetEncoder.Encoder {
    
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
    
    func boxEncodable <T: Encodable> (_ value: T) throws -> Data {
        
        if let data = value as? Data {
            return boxData(data)
        } else if let tlvEncodable = value as? ArtNetEncodable {
            return tlvEncodable.artNet
        } else {
            // encode using Encodable, should push new container.
            try value.encode(to: self)
            //let nestedContainer = stack.pop()
            //return nestedContainer.data
            fatalError()
        }
    }
}

private extension ArtNetEncoder.Encoder {
    
    func boxData(_ data: Data) -> Data {
        
        
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
        return Data(self.utf8)
    }
}
