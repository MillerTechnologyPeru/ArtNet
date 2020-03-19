//
//  ArtNzs.swift
//  
//
//  Created by Jorge Loc Rubio on 3/18/20.
//

import Foundation

public struct ArtNzs: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .nzs }
    
    public static let formatting = ArtNetFormatting(
        littleEndian: [CodingKeys.portAddress],
        data: [.lightingData: .lengthSpecifier]
    )
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /**
     The sequence number is used to ensure that ArtNzs packets are used in the correct order.
     When Art-Net is carried over a medium such as the internet,  it is possible that ArtNzs packets will reach the receiver out of order.
     This field  is incremented in the range `0x01` `to 0x0ff` to allow the receiving node to resequence packets.
     The Sequence field is set to `0x00` to disable this feature.
     */
    public var sequence: UInt8
    
    /// The DMX512 start code of this packet must not be Zero or RDM
    public var startCode: UInt8
    
    /// 15 bit Port-Address to which this packet is destined.
    public var portAddress: PortAddress
    
    /// The length of the data array.

    /// This value should be a number in the range 1 - 512.
    
    /// A variable length array of DMX512 lighting data.
    public var lightingData: Data
    
    // MARK: - Initialization
    
    public init(sequence: UInt8 = 0,
                startCode: UInt8 = 0,
                portAddress: PortAddress = 0,
                lightingData: Data = Data()) {
        
        self.protocolVersion = .current
        self.sequence = sequence
        self.startCode = startCode
        self.portAddress = portAddress
        self.lightingData = lightingData
    }
}
