//
//  ArtCommand.swift
//  
//
//  Created by Alsey Coleman Miller on 2/22/20.
//

/**
 The ArtCommand packet is used to send property set style commands.
 The packet can be unicast or broadcast, the decision beign application specific.
*/
import Foundation

public struct ArtCommand: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .command }
    
    public static let formatting = ArtNetFormatting(
        data: [CodingKeys.data: .lengthSpecifier]
    )
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// The ESTA manufacturer code.

    /// These codes are used to represent equipment manufacturer.
    /// They are assigned by ESTA.
    /// This field can be interpreted as two ASCII bytes representing the manufacturer initials.
    public var estaCode: ESTACode
    
    /// ASCII text command string, null terminated.
    /// Max length is 512 bytes including the null term.
    public var data: Data
    
    // MARK: - Initialization
    
    public init(estaCode: ESTACode,
                data: Data) {
        
        self.protocolVersion = .current
        self.estaCode = estaCode
        self.data = data
    }
}

// MARK: - Supporting Types

// MARK: - Command

/**
    The Data field contains the command text.
    The text is ASCII encoded and is null terminated and is case insensitive.
    It is legal, although inefficient, to set the Data array size to the maximun of 512 and null pad unused entries.
 
    The comman text may contain multiple commands and adheres to the following syntax:
            `Command=Data&`
    The ampersand is a break between commands. Also note that the text is capitalised for readability; it is case insensitive
 
    Thus far, two commands are defined by Art-Net.
    It is anticipated that additional commands will be added as other manufacturers register commands which have industry wide relevance.
 
    These commands shall be transmitted with EstaCode = `0xFFFF`
 */
public extension ArtCommand {

    struct Command: Codable {
        
        /// This command is used to re-programme the label associated with the ArtPollReply -> Swout fields.
        /// Syntax: `SwoutText=Playback&`
        let swoutText: String
        
        /// This command is used to re-programme the label associated with the ArtPollReply -> Swin fields.
        /// Syntax: `SwinText=Record&`
        let swinText: String
        
        /// Syntax: `Command=Data&`
        let command: String
        
        enum CodingKeys: String, CodingKey {
            
            case swoutText = "SwoutText"
            
            case swinText = "SwinText"
            
            case command = "Command"
        }
    }
}
