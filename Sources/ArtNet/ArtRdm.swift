//
//  File.swift
//  
//
//  Created by Jorge Loc Rubio on 3/10/20.
//

import Foundation

/**
This packet is used to transport all non-discovery RDM messages over Art-Net.
*/
public struct ArtRdm: ArtNetPacket, Equatable, Hashable, Codable {
    /// ArtNet packet code.
    public static var opCode: OpCode { return .rdm }
    
    public static let formatting = ArtNetFormatting(
        data: [CodingKeys.rdmPacket: .remainder]
    )
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Art-Net RDM version
    public let rdmVersion: RdmVersion
    
    /// Transmit as zero, receivers don’t test.
    internal let filler2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare1: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare3: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare4: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare5: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare6: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare7: UInt8
    
    /// The top 7 bits of the 15 bit Port-Address of Nodes that must respond to this packet.
    public var net: PortAddress.Net
    
    /// Command
    public var command: Command
    
    /// The low 8 bits of the Port-Address that should action this command.
    public var address: Address
    
    /// The RDM data packet excluding the DMX StartCode.
    public var rdmPacket: Data
    
    init(rdmVersion: RdmVersion = .standard,
         net: PortAddress.Net,
         command: Command = .arProcess,
         address: Address = 0,
         rdmPacket: Data) {
        
        self.protocolVersion = .current
        self.rdmVersion = rdmVersion
        self.filler2 = 0
        self.spare1 = 0
        self.spare2 = 0
        self.spare3 = 0
        self.spare4 = 0
        self.spare5 = 0
        self.spare6 = 0
        self.spare7 = 0
        self.net = net
        self.command = command
        self.address = address
        self.rdmPacket = rdmPacket
    }
}

public extension ArtRdm {
    
    /// Port-Address of the output gateway of this packet.
    var portAddress: PortAddress {
        return PortAddress(
            universe: address.universe,
            subnet: address.subnet,
            net: net
        )
    }
}

// MARK: - Supporting Types

public extension ArtRdm {
    
    /// Command
    enum Command: UInt8, Codable {
        
        /// Process RDM Packet
        case arProcess = 0x00
    }
}
