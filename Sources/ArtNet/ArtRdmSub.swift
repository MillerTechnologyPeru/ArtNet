//
//  ArtRdmSub.swift
//  
//
//  Created by Alsey Coleman Miller on 3/11/20.
//

import Foundation

/**
 The ArtRdmSub packet is used to transfer Get, Set, GetResponse and SetResponse data to and from multiple sub-devices within an RDM device. This packet is primarily used by Art-Net devices that proxy or emulate RDM. It offers very significant bandwidth gains over the approach of sending multiple ArtRdm packets.
 Please note that this packet was added at the release of Art-Net II. For backwards compatibility it is only acceptable to implement this packet in addition to ArtRdm. It must not be used instead of ArtRdm.
 */
public struct ArtRdmSub: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .rdmSub }
    
    public static let formatting = ArtNetFormatting(
        data: [CodingKeys.data: .remainder]
    )
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Art-Net rdm version
    public let rdmVersion: RdmVersion
    
    /// Transmit as zero, receivers don’t test.
    internal let filler2: UInt8
    
    /// UID of target RDM device.
    public let uid: MacAddress
    
    /// Transmit as zero, receivers don’t test.
    internal let spare1: UInt8
    
    /// As per RDM specification.
    /// This field defines whether this is a Get, Set, GetResponse, SetResponse.
    public let commandClass: CommandClass
    
    /// As per RDM specification. This field defines the type of parameter contained in this packet. Big- endian.
    public let parameterID: UInt16
    
    /// Defines the first device information contained in packet. This follows the RDM convention that 0 = root device and 1 = first subdevice. Big-endian.
    public let subDevice: UInt16
    
    /// The number of sub devices packed into packet. Zero is illegal. Big-endian.
    public let subCount: UInt16
    
    /// Transmit as zero, receivers don’t test.
    internal let spare2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare3: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare4: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare5: UInt8
    
    /// Packed 16-bit big-endian data.
    /// The size of the data array is defined by the contents of CommandClass and SubCount
    public let data: Data
    
    // MARK: - Initialization
    
    public init(rdmVersion: RdmVersion = .standard,
                uid: MacAddress,
                commandClass: CommandClass,
                parameterID: UInt16,
                subDevice: UInt16,
                subCount: UInt16,
                data: Data) {
        
        self.protocolVersion = .current
        self.rdmVersion = rdmVersion
        self.filler2 = 0
        self.uid = uid
        self.spare1 = 0
        self.commandClass = commandClass
        self.parameterID = parameterID
        self.subDevice = subDevice
        self.subCount = subCount
        self.spare2 = 0
        self.spare3 = 0
        self.spare4 = 0
        self.spare5 = 0
        self.data = data
    }
}

public extension ArtRdmSub {
    
    var commandData: [UInt16] {
        let size = dataSize
        guard size > 0,
            data.count == size * 2
            else { return [] }
        return (0 ..< size)
            .map { UInt16(bigEndian: UInt16(bytes: (data[$0], data[$0 + 1]))) }
    }
    
    internal var dataSize: Int {
        switch commandClass {
        case .get, .setResponse, .discovery:
            return 0
        case .set, .getResponse, .discoveryResponse:
            return Int(subCount)
        }
    }
}

// MARK: - Supporting Types

// MARK: - CommandClass

public extension ArtRdmSub {
    
    /// RDM Command Classes
    enum CommandClass: UInt8, Codable {
        
        case discovery              = 0x10
        case discoveryResponse      = 0x11
        case get                    = 0x20
        case getResponse            = 0x21
        case set                    = 0x30
        case setResponse            = 0x31
    }
}
