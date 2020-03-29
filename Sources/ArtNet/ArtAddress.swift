//
//  ArtAddress.swift
//  
//
//  Created by Jorge Loc Rubio on 3/18/20.
//

import Foundation

/**
    A Controller or monitorind device on the network can reprogram numerous controls of a  node remotely.
    This, for example, would allow the lighting console to re-route DMX512 data at remote locations. This is achieved by sending an ArtAddress packet to the Node's IP Address. ( The IP address is returned in the ArPoll packet).
    The node replies with an ArtPollReply packet.
 
    Fields `5` to `13` contain the data that will be programmed into the node.
*/
public struct ArtAddress: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .address }
    
    public static let formatting = ArtNetFormatting(
        string: [
            CodingKeys.shortName: .fixedLength(18),
            CodingKeys.longName:  .fixedLength(64)
        ]
    )
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Bits 14-8 of the 15 bit Port-Address are encoded into the bottom 7 bits of this field.
    /// This is used in combination with SubSwitch and SwIn[] or SwOut[] to produce the full universe address.

    /// This value is ignored unless bit 7 is high. i.e to program a value `0x07`, send the value as `0x87`.
    /// Send `0x00` to reset this value to the physical switch settig.
    /// Use value `0x7f` for no change
    public var netSwitch: ArtNet.PortAddress.Net
    
    /// The BindIndex definesthe bound node which originated this packed.
    
    /// In combination with Port and Source IP address, it uniquely identifies the sender.
    
    /// This must match the BindIndex field in ArtPollReply.
    
    /// This number represents the order of bound devices.
    
    /// A lower number means closer to root device. A value of 1 means root device.
    public var bindingIndex: UInt8
    
    /// The array represents a null terminated short name for the Node.
    ///
    /// The Controller uses the ArtAddress packet to program this string.
    /// Max length is 17 characters plus the null.
    /// The Node will ignore this value if the string is null.
    /// This is a fixed length field, although the string it contains can be shorter than the field.
    public var shortName: String
    
    /// The array represents a null terminated long name for the Node.
    ///
    /// The Controller uses the ArtAddress packet to program this string.
    /// Max length is 63 characters plus the null.
    /// The Node will ignore this value if the strung is null.
    /// This is a fixed length field, although the string it contains can be shorter than the field.
    public var longName: String
    
    /// Bits 3-0 of the 15 bit Port-Address for a given input port are encoded into the bottom 4 bits of this field.
    /// This is used in combination with NetSwitch and SubSwitch to produce the full universe address.

    /// This value is ignored unless bit 7 is high. i.e to program a value `0x07`, send the value as `0x87`.
    /// Send `0x00` to reset this value to the physical switch settig.
    /// Use value `0x7f` for no change
    public var inputAddresses: ChannelArray<PortAddress>
    
    /// Bits 3-0 of the 15 bit Port-Address for a given output port are encoded into the bottom 4 bits of this field.
    /// This is used in combination with NetSwitch and SubSwitch to produce the full universe address.
    
    /// This value is ignored unless bit 7 is high. i.e to program a value `0x07`, send the value as `0x87`.
    /// Send `0x00` to reset this value to the physical switch settig.
    /// Use value `0x7f` for no change
    public var outputAddresses: ChannelArray<PortAddress>
    
    /// Bits 7-4 of the 15 bit Port-Address are encoded into the bottom 4 bits of this field.
    /// This is used in combination with NetSwitch and SwIn[] or SwOut[] to produce the full universe address.
    
    /// This value is ignored unless bit 7 is high. i.e to program a value `0x07`, send the value as `0x87`.
    /// Send `0x00` to reset this value to the physical switch settig.
    /// Use value `0x7f` for no change
    public var subSwitch: ArtNet.PortAddress.SubNet
    
    /// Reserved,
    public var video: UInt8
    
    /// Node configuration command
    public var command: Command
    
    // MARK: - Initialization
    
    init(netSwitch: ArtNet.PortAddress.Net = 0,
         bindingIndex: UInt8 = 0,
         shortName: String,
         longName: String,
         inputAddresses: ChannelArray<PortAddress> = [],
         outputAddresses: ChannelArray<PortAddress> = [],
         subSwitch: ArtNet.PortAddress.SubNet = 0,
         video: UInt8 = 0,
         command: Command) {
        
        self.protocolVersion = .current
        self.netSwitch = netSwitch
        self.bindingIndex = bindingIndex
        self.shortName = shortName
        self.longName = longName
        self.inputAddresses = inputAddresses
        self.outputAddresses = outputAddresses
        self.subSwitch = subSwitch
        self.video = video
        self.command = command
    }
}

// MARK: - Supporting Types

// MARK: - Command

public extension ArtAddress {
    
    /// Command
    enum Command: UInt8, Codable {
        
        /// No action
        case none = 0x00
        
        /// If Node is currently in merge mode, cancel merge mode upon receipt of next ArtDmx packet.
        /// See discussion of merge mode operation.
        case cancelMerge = 0x01
        
        /// The front panel indicators of the Node operate normally.
        case ledNormal = 0x02
        
        /// The front panel indicators of the Node are disabled and switched off.
        case ledMute = 0x03
        
        /// Rapid flashing of the Node's front panel indicators.
        /// It is intended as an outlet identifier for large installations.
        case ledLocate = 0x04
        
        /// Resets the Node's Sip, Text, Test and data error flags.
        /// If an outout shot is beign flagged, forces the test to re-run.
        case resetRxFlags = 0x05
        
        /// Node configuration commands:
        ///
        /// Note that Ltp / Htp settings should be retained by the node during power cycling.
        
        /// Set DMX Port 0 to Merge in LTP mode.
        case mergeLtp0 = 0x10
        
        /// Set DMX Port 1 to Merge in LTP mode.
        case mergeLtp1 = 0x11
        
        /// Set DMX Port 2 to Merge in LTP mode.
        case mergeLtp2 = 0x12
        
        /// Set DMX Port 3 to Merge in LTP mode.
        case mergeLtp3 = 0x13
        
        /// Set DMX Port 0  to Merge in HTP (default) mode.
        case mergeHtp0 = 0x50
        
        /// Set DMX Port 1  to Merge in HTP (default) mode.
        case mergeHtp1 = 0x51
        
        /// Set DMX Port 2  to Merge in HTP (default) mode.
        case mergeHtp2 = 0x52
        
        /// Set DMX Port 3  to Merge in HTP (default) mode.
        case mergeHtp3 = 0x53
        
        /// Set DMX Port 0 to outout both DMX512 and RDM packets from the Art-net protocol (default).
        case artNetSelected0 = 0x60
        
        /// Set DMX Port 1 to outout both DMX512 and RDM packets from the Art-net protocol (default).
        case artNetSelected1 = 0x61
        
        /// Set DMX Port 2 to outout both DMX512 and RDM packets from the Art-net protocol (default).
        case artNetSelected2 = 0x62
        
        /// Set DMX Port 3 to outout both DMX512 and RDM packets from the Art-net protocol (default).
        case artNetSelected3 = 0x63
        
        /// Set DMX Port 0 to output DMX512 data from the sACN protocol and RDM data from the Art-Net protocol.
        case acnSelected0 = 0x70
        
        /// Set DMX Port 1 to output DMX512 data from the sACN protocol and RDM data from the Art-Net protocol.
        case acnSelected1 = 0x71
        
        /// Set DMX Port 2 to output DMX512 data from the sACN protocol and RDM data from the Art-Net protocol.
        case acnSelected2 = 0x72
        
        /// Set DMX Port 3 to output DMX512 data from the sACN protocol and RDM data from the Art-Net protocol.
        case acnSelected3 = 0x73
        
        /// Clear DMX Output buffer for Port 0
        case clearOutput0 = 0x90
        
        /// Clear DMX Output buffer for Port 1
        case clearOutput1 = 0x91
        
        /// Clear DMX Output buffer for Port 2
        case clearOutput2 = 0x92
        
        /// Clear DMX Output buffer for Port 3
        case clearOutput3 = 0x93
    }
}

// MARK: - PortAddress

public extension ArtAddress {
    
    struct PortAddress: RawRepresentable, Codable, Equatable, Hashable {
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: CustomStringConvertible

extension ArtAddress.PortAddress: CustomStringConvertible {
    
    public var description: String {
        return "0x" + rawValue.toHexadecimal()
    }
}

// MARK: ExpressibleByIntegerLiteral

extension ArtAddress.PortAddress: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}
