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
    
    /*public static let formatting = ArtNetFormatting(
        littleEndian: [CodingKeys.portAddress],
        data: [CodingKeys.vlcData: .lengthSpecifier]
    )*/
    
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
    public let startCode: UInt8
    
    /// 15 bit Port-Address to which this packet is destined.
    public var portAddress: PortAddress
    
    /// The length of the Vlc data array.
    /// This value should be in the range 1 - 512
    /// it represents the number of DMX512 channels encoded in packet.
    public var length: UInt16
    
    /// A variable lenght Array of VLC data
    public var data: [UInt8]
    
    // MARK: - Initialization
}

// MARK: - Supporting Types

// MARK: - VLCArrayData

public extension ArtVlc {
    
    struct VlcArrayData: Equatable, Hashable, Codable {
    
        /// Magic number used to identify this packet `0x41` high bit, `0x4C` low bit
        internal let manId: UInt16 // { return UInt16(bigEndian: UInt16(bytes: 0x41, 0x4C)) }
        
        /// Magic number used to identify this packet `0x45`
        internal let subCode: Int8 // { return 0x45 }
        
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
        public var spare1: UInt8
        
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
    }
}

public extension ArtVlc {
    
    var vlcData: [UInt8]
    
    internal var dataSize: Int { return Int(length) }
}


// MARK: VLCArray Supporting Types

// MARK: VLC Flags

public extension ArtVlc.VlcArrayData {
    
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

public extension ArtVlc.VlcArrayData {
    
    enum LanguageCodes: UInt16, Codable {
        
        /// Payload contains a simple text string representing a URL
        case beaconURL = 0x0000
    
        /// Payload contains a simple ASCII text message.
        case beaconText = 0x0001
    }
}
