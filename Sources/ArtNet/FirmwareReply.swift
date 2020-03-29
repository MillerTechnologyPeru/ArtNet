//
//  FirmwareReply.swift
//  
//
//  Created by Jorge Loc Rubio on 3/17/20.
//

/**
This packet is send by the Node to the Controller in acknowledgement of each OpFirmwareMaster packet.
*/
public struct FirmwareReply: ArtNetPacket, Equatable, Hashable, Codable {
    /// ArtNet packet code.
    public static var opCode: OpCode { return .firmwareReply }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Transmit as zero, receivers don’t test.
    internal let filler1: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let filler2: UInt8
    
    /// Defines the packet contents as follows.
    /// Codes are used for both firmware and UBEA.
    public var statusCode: StatusCode
    
    /// Node sets to zero, Controller does not test.
    internal let spare: [UInt8]
    
    
    // MARK: - Initialization
    
    public init(statusCode: StatusCode) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.statusCode = statusCode
        self.spare = [UInt8](repeating: 0x00, count: 21)
    }
}

// MARK: - Supporting Types

// MARK: - Type

public extension FirmwareReply {

    /// FirmwareReply Type Codes
    enum StatusCode: UInt8, Codable, CaseIterable {
        
        /// Last packet received successfully..
        case blockGood  = 0x00
        
        /// All firmware received successfully..
        case allGood    = 0x01
        
        /// Firmware upload failed. (All error conditions).
        case fail   = 0xff
    }
}
