//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

internal extension ArtNetPacket {
    
    
    static let id = "Art-Net"
}

internal struct ArtNetHeader {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    let id: ID
    
    /// Opcode of
    let opCode: OpCode
}

internal extension ArtNetHeader {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    struct ID: RawRepresentable, Equatable, Hashable {
        
        let bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
            self.bytes = bytes
        }
    }
}

extension ArtNetHeader.ID {
    
    static let artNet = ArtNetHeader.ID(raw
}

extension ArtNetHeader.ID: RawRepresentable {
    
    init?(rawValue: String) {
        
        guard rawValue.utf8.count == 7
            else { return nil }
        
        self.init(bytes: (rawValue.utf8[0], rawValue.utf8[1], rawValue.utf8[2], rawValue.utf8[3], rawValue.utf8[4], rawValue.utf8[5], rawValue.utf8[6], 0))
    }
    
    var rawValue: String {
        return String()
    }
}

extension ArtNetHeader.ID: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}
