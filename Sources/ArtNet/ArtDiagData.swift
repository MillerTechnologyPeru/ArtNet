//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

/**
 ArtDiagData is a general purpose packet that allows a node or controller to send diagnostics data for display.
 The ArtPoll packet sent by controllers defines the destination to which these messages should be sent.
 */
public struct DiagnosticData: Equatable, Hashable, Codable {
    
    
}

public typealias ArtDiagData = DiagnosticData

// MARK: - Supporting Types

/// Diagnostics Priority codes
public enum DiagnosticPriority: UInt8, Codable, CaseIterable {
    
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
