//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

internal struct ArtNetHeader {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    let id: ID
    
    /// Opcode of
    let opCode: OpCode
}



// MARK: - Supporting Types

internal extension ArtNetHeader {
    
    /// Array of 8 characters, the final character is a null termination.
    ///
    /// Value = `‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00`
    struct ID: RawRepresentable, Equatable, Hashable {
        
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

extension ArtNetHeader.ID {
    
    init?(data: Data) {
        guard let string = data.withUnsafeBytes({
            $0.baseAddress.flatMap { String(validatingUTF8: $0.assumingMemoryBound(to: CChar.self)) }
        }) else { return nil }
        self.rawValue = string
    }
    
    var data: Data {
        return Data(unsafeBitCast(rawValue.utf8CString, to: ContiguousArray<UInt8>.self))
    }
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
