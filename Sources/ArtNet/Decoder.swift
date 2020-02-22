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
        
        log?("Will decode \(T.opCode)")
        
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
                
        /// Input formatting
        let formatting: ArtNetFormatting
        
        /// Input Data
        let data: Data
        
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
