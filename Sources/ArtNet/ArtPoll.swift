//
//  ArtPoll.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

import Foundation

/**
 The ArtPoll packet is used to discover the presence of other Controllers, Nodes and Media Servers. The ArtPoll packet is only sent by a Controller. Both Controllers and Nodes respond to the packet.
 
 A Controller broadcasts an ArtPoll packet to IP address 2.255.255.255 (sub-net mask 255.0.0.0) at UDP port 0x1936, this is the Directed Broadcast address.
 The Controller may assume a maximum timeout of 3 seconds between sending ArtPoll and receiving all ArtPollReply packets. If the Controller does not receive a response in this time it should consider the Node to have disconnected.
 The Controller that broadcasts an ArtPoll should also reply to its own message (to Directed Broadcast address) with an ArtPollReply. This ensures that any other Controllers listening to the network will detect all devices without the need for all Controllers connected to the network to send ArtPoll packets. It is a requirement of Art-Net that all
 Art-Net 4 Protocol Release V1.4 Document Revision 1.4dd 22/1/2017 - 12 -
 controllers broadcast an ArtPoll every 2.5 to 3 seconds. This ensures that any network devices can easily detect a disconnect.
 Multiple Controllers
 Art-Net allows and supports multiple controllers on a network. When there are multiple controllers, Nodes will receive ArtPolls from different controllers which may contain conflicting diagnostics requirements. This is resolved as follows:
 If any controller requests diagnostics, the node will send diagnostics. (ArtPoll->TalkToMe- >2).
 If there are multiple controllers requesting diagnostics, diagnostics shall be broadcast. (Ignore ArtPoll->TalkToMe->3).
 The lowest minimum value of Priority shall be used. (Ignore ArtPoll->Priority).
 */
public struct ArtPoll: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .poll }
    
    /// Art-Net formatting
    public static let formatting = ArtNetFormatting(
        littleEndian: [CodingKeys.protocolVersion]
    )
    
    /// Art-Net protocol revision.
    public var protocolVersion: ProtocolVersion
    
    /// Set behaviour of Node.
    public var behavior: BitMaskOptionSet<Behavior>
    
    /// The lowest priority of diagnostics message that should be sent.
    public var priority: DiagnosticPriority
    
    public init(protocolVersion: ProtocolVersion = .current,
                behavior: BitMaskOptionSet<Behavior> = [],
                priority: DiagnosticPriority = .low) {
        
        self.protocolVersion = protocolVersion
        self.behavior = behavior
        self.priority = priority
    }
}

public extension ArtPoll {
    
    /// Set behaviour of Node
    enum Behavior: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Send ArtPollReply whenever Node conditions change.
        /// This selection allows the Controller to be informed of changes without the need to continuously poll.
        /// If not set, then only send ArtPollReply in response to an ArtPoll or ArtAddress.
        case replyWithoutPolling            = 0b00000001
        
        /// Send me diagnostics messages.
        case diagnostics                    = 0b00000010
        
        /// Diagnostics messages are unicast.
        /// If not set, diagnostics messages are broadcast.
        case unicastDiagnostics             = 0b00000100
        
        /// Disable VLC transmission. If not set then VLC transmission is enabled.
        case disableVLC                     = 0b00001000
    }
}
