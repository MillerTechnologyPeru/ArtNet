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
        
        var data = Data(capacity: 10 + MemoryLayout<T>.size(ofValue: value))
        let header = ArtNetHeader(id: .artNet, opCode: T.opCode)
        try encode(header, &data) // encode Art-Net header first
        try encode(value, &data)
        return data
    }
    
    internal func encode <T: Encodable> (_ value: T, _ data: inout Data) throws {
        
        
    }
    
    
}

