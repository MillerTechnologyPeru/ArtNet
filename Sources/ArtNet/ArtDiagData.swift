//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

import Foundation

/**
 ArtDiagData is a general purpose packet that allows a node or controller to send diagnostics data for display.
 The ArtPoll packet sent by controllers defines the destination to which these messages should be sent.
 */
public struct DiagnosticData: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .diagnostics }
    
    public static let formatting = ArtNetFormatting(
        data: [CodingKeys.data: .lengthSpecifier]
    )
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Ignore by receiver, set to zero by sender.
    internal let filler1: UInt8
    
    /// The priority of this diagnostic data. See `DiagnosticPriority`
    public var priority: DiagnosticPriority
    
    /// Ignore by receiver, set to zero by sender.
    internal let filler2: UInt8
    
    /// Ignore by receiver, set to zero by sender.
    internal let filler3: UInt8
    
    /// ACSII text array, nill terminated. Max length is 512 bytes including the null terminator.
    public var data: Data
    
    // MARK: - Initialization
    
    public init(priority: DiagnosticPriority,
                data: Data) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.priority = priority
        self.filler2 = 0
        self.filler3 = 0
        self.data = data
    }
}

public typealias ArtDiagData = DiagnosticData

// MARK: - Supporting Types

/// Diagnostics Priority codes
public enum DiagnosticPriority: UInt8, Codable, CaseIterable {
    
    /// Send all diagnostics. 
    case all        = 0x00
    
    /// Low priority message.
    case low        = 0x10
    
    /// Medium priority message.
    case medium     = 0x40
    
    /// High priority message.
    case high       = 0x80
    
    /// Critical priority message.
    case critical   = 0xe0
    
    /// Volatile message. Messages of this type are displayed on a single line in the DMX-Workshop diagnostics display.
    /// All other types are displayed in a list box.
    case volatile   = 0xf0
}
