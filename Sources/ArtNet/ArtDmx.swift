//
//  ArtDmx.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

/**
 ArtDmx is the data packet used to transfer DMX512 data. The format is identical for Node to Controller, Node to Node and Controller to Node.
 
 The Data is output through the DMX O/P port corresponding to the Universe setting. In the absence of received ArtDmx packets, each DMX O/P port re-transmits the same frame continuously.
 The first complete DMX frame received at each input port is placed in an ArtDmx packet as above and transmitted as an ArtDmx packet containing the relevant Universe parameter. Each subsequent DMX frame containing new data (different length or different contents) is also transmitted as an ArtDmx packet.
 Nodes do not transmit ArtDmx for DMX512 inputs that have not received data since power on.
 However, an input that is active but not changing, will re-transmit the last valid ArtDmx packet at approximately 4-second intervals. (Note. In order to converge the needs of Art- Net and sACN it is recommended that Art-Net devices actually use a re-transmit time of 800mS to 1000mS).
 
 A DMX input that fails will not continue to transmit ArtDmx data.
 
 - Refresh Rate: The ArtDmx packet is intended to transfer DMX512 data. For this reason, the ArtDmx packet for a specific IP Address should not be transmitted at a repeat rate faster than the maximum repeat rate of a DMX packet containing 512 data slots.
 
 - Synchronous Data: In video or media-wall applications, the ability to synchronise multiple universes of ArtDmx is beneficial. This can be achieved with the ArtSync packet.
 
 - Data Merging: The Art-Net protocol allows multiple nodes or controllers to transmit ArtDmx data to the same universe.
 A node can detect this situation by comparing the IP addresses of received ArtDmx packets. If ArtDmx packets addressed to the same Universe are received from different IP addresses, a potential conflict exists.
 */
public struct ArtDmx: ArtNetPacket, Equatable, Hashable, Codable {

    /// ArtNet packet code.
    public static var opCode: OpCode { return .dmx }
    
    public static let formatting = ArtNetFormatting(
        littleEndian: [CodingKeys.universe],
        data: [.lightingData: .lengthSpecifier]
    )
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /**
     The sequence number is used to ensure that
     ArtDmx packets are used in the correct order. When Art-Net is carried over a medium such as the Internet, it is possible that ArtDmx packets will reach the receiver out of order.
     This field is incremented in the range `0x01` to `0xff `to allow the receiving node to resequence packets.
     The Sequence field is set to `0x00` to disable this feature.
     */
    public var sequence: UInt8
    
    /**
     The physical input port from which DMX512 data was input.
     
     - Note: This field is for information only. Use Universe for data routing.
     */
    public var physical: UInt8
    
    /// 15 bit Port-Address to which this packet is destined.
    public var universe: UInt16
    
    /// A variable length array of DMX512 lighting data.
    public var lightingData: Data
    
    public init(sequence: UInt8 = 0,
                physical: UInt8 = 0,
                universe: UInt16 = 0,
                lightingData: Data = Data()) {
        
        self.protocolVersion = .current
        self.sequence = sequence
        self.physical = physical
        self.universe = universe
        self.lightingData = lightingData
    }
}
