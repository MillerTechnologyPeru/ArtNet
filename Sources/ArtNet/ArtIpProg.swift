//
//  ArtIpProg.swift
//  
//
//  Created by Jorge Loc Rubio on 3/23/20.
//

import Foundation

/**
 The ArtIpProg packet allows the IP settings of a Node to be reprogrammed.
  
 The ArtIpProg packet is sent by a Controller to the private address of a Node. If the Node supports remote programming of IP address, it will respond with an ArtIpProgReply packet.
 In all scenarios, the ArtIpProgReply is send to the private address of the sender.
 */
public struct ArtIpProg: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .ipProgram }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler2: UInt8
    
    /// Command
    public var command: BitMaskOptionSet<Command>
    
    /// Set to zero. Pads data structure for word alignment.
    internal let filler4: UInt8
    
    /// IP Address to be programmed into Node if enabled by Command Field
    public var ip: NetworkAddress.IPv4
    
    /// Subnet mask to be programmed into Node if enabled by Command Field
    public var subnet: SubnetMask
    
    /// (Deprecated)
    internal let port: UInt16
    
    /// Transmit as zero, receivers dont test.
    internal let spare1: UInt8
    
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
    
    public init(command: BitMaskOptionSet<Command> = [],
                ip: NetworkAddress.IPv4,
                subnet: SubnetMask) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.command = command
        self.filler4 = 0
        self.ip = ip
        self.subnet = subnet
        self.port = 0
        self.spare1 = 0
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

public extension ArtIpProg {
    
    /// Defines the how this packet is processed.
    /// If all bits are clear, this is an enquiry only.
    enum Command: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Program Port
        case programPort        = 0b00000001
        
        /// Program Subnet Mask
        case programSubnet      = 0b00000010
        
        /// Program IP Address
        case programIPAddress   = 0b00000100
        
        /// Set to return all three parameters to default
        case setDefault         = 0b00001000
        
        /// Set to enable DHCP (if set ignore lower bits).
        case enableDHCP         = 0b01000000
        
        /// Set to enable any programming.
        case enableProgramming  = 0b10000000
    }
}
