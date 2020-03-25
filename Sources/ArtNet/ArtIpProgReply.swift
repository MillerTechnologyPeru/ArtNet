//
//  ArtIpProgReply.swift
//  
//
//  Created by Jorge Loc Rubio on 3/24/20.
//

import Foundation

/**
  The ArtIpProgReply packet is issed by a Node in response to an ArtIpProg packet.
  Nodes that do not support remote programming of IP address do not reply to ArtIpProg packts.
  In all scenarios, the ArtIpProgReply is sent to the private address of the sender.
 */
public struct ArtIpProgReply: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .ipProgramReply }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler2: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler3: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler4: UInt8
    
    /// IP Address of Node.
    public var ip: NetworkAddress.IPv4
    
    /// Subnet mask of Node.
    public var subnet: SubnetMask
    
    /// (Deprecated).
    internal let port: UInt16
    
    /// Status
    public var status: Status
    
    /// Transmit as zero, receivers dont test.
    internal let spare2: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare3: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare4: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare5: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare6: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare7: UInt8
    
    /// Transmit as zero, receivers dont test.
    internal let spare8: UInt8
    
    // MARK: - Initialization
    
    public init(ip: NetworkAddress.IPv4,
                subnet: SubnetMask,
                status: Status) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.filler3 = 0
        self.filler4 = 0
        self.ip = ip
        self.subnet = subnet
        self.port = 0
        self.status = status
        self.spare2 = 0
        self.spare3 = 0
        self.spare4 = 0
        self.spare5 = 0
        self.spare6 = 0
        self.spare7 = 0
        self.spare8 = 0
    }
}

// MARK: - Supporting Types

// MARK: - Command

public extension ArtIpProgReply {
    
    enum Status: UInt8, Codable, CaseIterable {
        
        /// 0
        case none           = 0b00000000
        
        /// DHCP enabled.
        case dhcpEnabled    = 0b01000000
    }
}
