//
//  ArtVlc.swift
//  
//
//  Created by Jorge Loc Rubio on 3/25/20.
//

import Foundation

/**
  ArtVlc is a specific implementation of the ArtNzs packet which is used for the transfer of VLC (Visible Light Communication) data over Art-Net. (The packet's payload can also be used to transfer VLC over DMX512 physical layer).
 
  Fileds `2`, `6`, `11`, `12` and `13` should be treated as `magic numbers` to detect this packet.
 */
public struct ArtVlc: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .nzs }
    
    public static let formatting = ArtNetFormatting(
        littleEndian: [CodingKeys.portAddress],
        data: [CodingKeys.data: .lengthSpecifier]
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
    
    /// The DMX512 start code of this packet is set to `0x91` No other values are allowed.
    internal let startCode: UInt8
    
    /// 15 bit Port-Address to which this packet is destined.
    public var portAddress: PortAddress
    
    /// The length of the Vlc data array.
    /// This value should be in the range 1 - 512
    /// it represents the number of DMX512 channels encoded in packet.
    public var length: UInt16
    
    /// A variable lenght Array of VLC data
    public var data: VlcData
    
    // MARK: - Initialization
    
    public init(sequence: UInt8,
                portAddress: PortAddress,
                length: UInt16,
                data: VlcData) {
        
        self.protocolVersion = .current
        self.sequence = sequence
        self.startCode = 0x91
        self.portAddress = portAddress
        self.length = length
        self.data = data
    }
}

// MARK: - Supporting Types

// MARK: - VLCArrayData

public extension ArtVlc {
    
    struct VlcData: Equatable, Hashable, Codable {
    
        /// Magic number used to identify this packet `0x41` high bit, `0x4C` low bit
        internal let manId: UInt16
        
        /// Magic number used to identify this packet `0x45`
        internal let subCode: UInt8 // { return 0x45 }
        
        /// VLC Flags
        public var flags: BitMaskOptionSet<VlcFlags>
        
        /// The transaction number is a 16-bit value which allows VLC transactions to be synchronised.
        /// A value of `0` indicates the first packet in a transaction.
        /// A value of `0xFFFF` indicates the final packet in the transaction.
        /// All other packets contain consecutive numbers which increment on each packet and roll over to `1` at `0xFFFE`
        public var transaction: UInt16
        
        /// The slot number, range 1 - 512, of the device to which this packet is directed.
        /// A value of `0` indicates that all devices attached to this packet's Port-Address should accept the packet.
        public var slotAddress: UInt16
        
        /// The 16-bit payload size in the range 0 to 480
        public var payloadCount: UInt16
        
        /// the 16-bit unsigned additive checksum of the data in the payload
        public var payloadChecksum: UInt16
        
        /// Transmit as zero, receive does not check.
        internal let spare1: UInt8
        
        /// The 8-bit VLC modulation depth expressed as a percentage in the range 1 to 100.
        /// A value of `0` indicates that the transmitter should use its default value
        public var depth: UInt8
        
        /// The 16-bit modulation frequency of the VLC transmitter expressed in Hz.
        /// A value of `0` indicates that the transmmitter should use its default value.
        public var frequency: UInt16
        
        /// The 16-bit modulation type number that the transmitter should use to transmit VLC.
        /// `0x0000` Use transmitter default.
        public var modulation: UInt16
        
        /// The 16-bit payload language code.
        public var languageCode: LanguageCodes
        
        /// The 16-bit beacon mode repeat frecuency.
        /// If flags Beacon is set, this 16-bit value indicates the frequency in Hertz at which the VLC packet should be repeated.
        /// `0x0000` Use transmitter default.
        public var beaconRepeat: UInt16
        
        /// The actual VLC payload
        public var payload: Data
        
        // MARK: - Initialization
        
        public init(flags: BitMaskOptionSet<VlcFlags>,
                    transaction: UInt16,
                    slotAddress: UInt16,
                    payloadCount: UInt16,
                    payloadChecksum: UInt16,
                    depth: UInt8,
                    frequency: UInt16,
                    modulation: UInt16,
                    languageCode: LanguageCodes,
                    beaconRepeat: UInt16,
                    payload: Data) {
            
            // 0 - 1
            self.manId = UInt16(bigEndian: UInt16(bytes: (0x41, 0x4C)))
            // 2
            self.subCode = 0x45
            // 3
            self.flags = flags
            // 4 - 5
            self.transaction = transaction
            // 6 - 7
            self.slotAddress = slotAddress
            // 8 - 9
            self.payloadCount = payloadCount
            // 10 - 11
            self.payloadChecksum = payloadChecksum
            // 12
            self.spare1 = 0
            // 13
            self.depth = depth
            // 14 - 15
            self.frequency = frequency
            // 16 - 17
            self.modulation = modulation
            // 18 - 19
            self.languageCode = languageCode
            // 20 - 21
            self.beaconRepeat = beaconRepeat
            // 22 - 502?
            self.payload = payload
        }
    }
}

public extension ArtVlc {
    
    var vlcArrayData: [UInt8] {
        let size = dataSize
        guard size > 0 && size <= 502
            else { return [] }
        
        var array: [UInt8] = []
        for index:Int in 0 ..< size {
            /// manId
            if index == 0 {
                array.append(data.manId.bytes.1)
                array.append(data.manId.bytes.0)
            }
            
            /// subCode
            if index == 2 {
                array.append(data.subCode)
            }
            
            /// flags
            if index == 3 {
                array.append(data.flags.rawValue)
            }
            
            /// transaction
            if index == 4 {
                array.append(data.transaction.bytes.1)
                array.append(data.transaction.bytes.0)
            }
            
            /// slotAddress
            if index == 6 {
                array.append(data.slotAddress.bytes.1)
                array.append(data.slotAddress.bytes.0)
            }
            
            /// payloadCount
            if index == 8 {
                array.append(data.payloadCount.bytes.1)
                array.append(data.payloadCount.bytes.0)
            }
            
            /// payloadChecksum
            if index == 10 {
                array.append(data.payloadChecksum.bytes.1)
                array.append(data.payloadChecksum.bytes.0)
            }
            
            /// spare1
            if index == 12 {
                array.append(data.spare1)
            }
            
            /// depth
            if index == 13 {
                array.append(data.depth)
            }
            
            /// frequency
            if index == 14 {
                array.append(data.frequency.bytes.1)
                array.append(data.frequency.bytes.0)
            }
            
            /// modulation
            if index == 16 {
                array.append(data.modulation.bytes.1)
                array.append(data.modulation.bytes.0)
            }
            
            /// languageCode
            if index == 18 {
                array.append(data.languageCode.rawValue.bytes.1)
                array.append(data.languageCode.rawValue.bytes.0)
            }
            
            /// beaconRepeat
            if index == 20 {
                array.append(data.beaconRepeat.bytes.1)
                array.append(data.beaconRepeat.bytes.0)
            }
            
            /// payload
            if index == 22 {
                array.append(contentsOf: Array(data.payload))
                break
            }
        }
        return array
    }
    
    internal var dataSize: Int { return Int(length) }
}

// MARK: VLCArray Supporting Types

// MARK: VLC Flags

public extension ArtVlc.VlcData {
    
    /// Bit fields used to control VLC operations.
    
    /// Bits that are unused shall be transmitted as zero.
    enum VlcFlags: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// If set, data in the payload area shall be interpreted as IEEE VLC data.
        
        /// if clear, PayLanguage defines the payload contents.
        case leee           = 0b10000000
        
        /// If set this is a reply packet that is in response to the request sent with matching number in the transaction number: TransHi/Lo.
        
        /// If clear this is not a reply.
        case reply          = 0b01000000
        
        /// If set, this is a reply packet that is in response to the request sent with matching number in the transaction number: TransHi/Lo.
        
        /// If clear this is not a reply.
        case beacon         = 0b00100000
    }
}

// MARK: Language Codes

public extension ArtVlc.VlcData {
    
    enum LanguageCodes: UInt16, Codable {
        
        /// Payload contains a simple text string representing a URL
        case beaconURL = 0x0000
    
        /// Payload contains a simple ASCII text message.
        case beaconText = 0x0001
    }
}
