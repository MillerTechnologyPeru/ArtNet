//
//  ArtPoll.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

import Foundation

/// ArtNet Polling Packet
public struct Poll: Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .poll }
    
    /// Set behaviour of Node.
    public var behavior: BitMaskOptionSet<Behavior>
    
    /// The lowest priority of diagnostics message that should be sent.
    public var priority: DiagnosticPriority
}

public typealias ArtPoll = Poll

public extension Poll {
    
    /// Set behaviour of Node
    enum Behavior: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Send ArtPollReply whenever Node conditions change.
        /// This selection allows the Controller to be informed of changes without the need to continuously poll.
        /// If not set, then only send ArtPollReply in response to an ArtPoll or ArtAddress.
        case replyWithoutPolling            = 0b0000001
        
        /// Send me diagnostics messages.
        case diagnostics                    = 0b0000010
        
        /// Diagnostics messages are unicast.
        /// If not set, diagnostics messages are broadcast.
        case unicastDiagnostics             = 0b0000100
        
        /// Disable VLC transmission. If not set then VLC transmission is enabled.
        case disableVLC                     = 0b0001000
    }
}
