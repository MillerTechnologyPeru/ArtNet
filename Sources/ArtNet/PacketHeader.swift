//
//  PacketHeader.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

internal struct ArtNetHeader: Codable, Equatable, Hashable {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    let id: ID
    
    /// Opcode of the packet.
    let opCode: OpCode
}

internal extension ArtNetHeader {
    
    static let formatting = ArtNetFormatting(
        littleEndian: [ArtNetHeader.CodingKeys.opCode]
    )
}

// MARK: - Supporting Types

internal extension ArtNetHeader {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    struct ID: RawRepresentable, Equatable, Hashable, Codable {
        
        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension ArtNetHeader.ID {
    
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    static let artNet: ArtNetHeader.ID = "Art-Net"
}

// MARK: - CustomStringConvertible

extension ArtNetHeader.ID: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}

// MARK: - ExpressibleByStringLiteral

extension ArtNetHeader.ID: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
