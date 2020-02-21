//
//  ArtPollReply.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

/**
 A device, in response to a Controller’s ArtPoll, sends the ArtPollReply.
 
 This packet is also broadcast to the Directed Broadcast address by all Art-Net devices on power up.
 */
public struct PollReply: Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .pollReply }
    
    /// Node’s IP address.
    ///
    /// When binding is implemented, bound nodes may share the root node’s IP Address and the BindIndex is used to differentiate the nodes.
    public var address: Address.IPv4
    
    /// The Port is always 0x1936
    public let port: UInt16 = 0x1936
    
    /// Node’s firmware revision number.
    ///
    /// The Controller should only use this field to decide if a firmware update should proceed.
    /// The convention is that a higher number is a more recent release of firmware.
    public var firmwareVersion: UInt16
    
    /// Bits 14-8 of the 15 bit Port-Address are encoded into the bottom 7 bits of this field.
    /// This is used in combination with SubSwitch and SwIn[] or SwOut[] to produce the full universe address.
    public var netSwitch: UInt8
    
    /// Bits 7-4 of the 15 bit Port-Address are encoded into the bottom 4 bits of this field.
    /// This is used in combination with NetSwitch and SwIn[] or SwOut[] to produce the full universe address.
    public var subSwitch: UInt8
    
    /// The Oem word describes the equipment vendor and the feature set available.
    /// Bit 15 high indicates extended features available.
    public var oem: OEMCode
    
    /// Ubea Version
    ///
    /// This field contains the firmware version of the User Bios Extension Area (UBEA).
    /// If the UBEA is not programmed, this field contains zero.
    public var ubeaVersion: UInt8
    
    /// General Status register
    public var status1: Status1
    
    /// The ESTA manufacturer code.
    ///
    /// These codes are used to represent equipment manufacturer.
    /// They are assigned by ESTA.
    /// This field can be interpreted as two ASCII bytes representing the manufacturer initials.
    //public var estaCode:
}

// MARK: - Supporting Types

// MARK: - Status1

public extension PollReply {
    
    /// General Status register
    enum Status1: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// UBEA present.
        case ubea               = 0b00000001
        
        /// Capable of Remote Device Management (RDM).
        case rdm                = 0b00000010
        
        /// Booted from ROM.
        ///
        /// If not set then, normal firmware boot (from flash).
        case rom                = 0b00000100
        
        /// All Port-Address set by front panel controls.
        case addressFrontPanel  = 0b00010000
        
        /// All or part of Port-Address programmed by network or Web browser.
        case addressNetwork     = 0b00100000
        
        /// Indicators in Locate / IdentifyMode.
        case indicatorIdentify  = 0b01000000
        
        /// Indicators in Mute Mode
        case indicatorMute      = 0b10000000
        
        public static let indicatorNormal: BitMaskOptionSet<Status1> = [.indicatorIdentify, .indicatorMute]
    }
}

