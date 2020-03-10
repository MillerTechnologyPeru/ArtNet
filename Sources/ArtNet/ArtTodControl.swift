//
//  ArtTodControl.swift
//
//
//  Created by Jorge Loc Rubio on 3/9/20.
//

import Foundation

/**
 This packed is used to send RDM control parameters over Art-Net. the response is ArtTodData
 */
struct ArtTodControl: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .todControl }
        
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// Pad length to match ArtPoll.
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
    
    /// The low byte of the 15 bit Port-Address of the DMX Port that should action this command.
    public var address: Address
    
    public init(net: PortAddress.Net,
                command: Command = .none,
                addresses: Address = 0) {
        
        self.protocolVersion = .current
        self.filler1 = 0
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
    }
}

// MARK: - Command

public extension ArtTodControl {
    
    /// Command
    enum Command: UInt8, Codable {
        
        /// No action.
        case none = 0x00
        
        /// The node flushes its TOD and instigates full discovery.
        case flush = 0x01
    }
}
