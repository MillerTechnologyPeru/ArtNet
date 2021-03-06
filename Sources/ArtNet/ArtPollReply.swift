//
//  ArtPollReply.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

import Foundation

/**
 A device, in response to a Controller’s ArtPoll, sends the ArtPollReply.
 
 This packet is also broadcast to the Directed Broadcast address by all Art-Net devices on power up.
 */
public struct ArtPollReply: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .pollReply }
    
    /// Art-Net formatting
    public static let formatting = ArtNetFormatting(
        littleEndian: [
            CodingKeys.port,
            .estaCode,
        ],
        data: [
            .filler: .remainder
        ],
        string: [
            .shortName: .fixedLength(18),
            .longName:  .fixedLength(64),
            .nodeReport: .fixedLength(64)
        ]
    )
    
    // MARK: - Properties
    
    /// Node’s IP address.
    ///
    /// When binding is implemented, bound nodes may share the root node’s IP Address and the BindIndex is used to differentiate the nodes.
    public var address: NetworkAddress.IPv4
    
    /// The Port is always 0x1936
    public let port: UInt16
    
    /// Node’s firmware revision number.
    ///
    /// The Controller should only use this field to decide if a firmware update should proceed.
    /// The convention is that a higher number is a more recent release of firmware.
    public var firmwareVersion: UInt16
    
    /// Bits 14-8 of the 15 bit Port-Address are encoded into the bottom 7 bits of this field.
    /// This is used in combination with SubSwitch and SwIn[] or SwOut[] to produce the full universe address.
    public var netSwitch: ArtNet.PortAddress.Net
    
    /// Bits 7-4 of the 15 bit Port-Address are encoded into the bottom 4 bits of this field.
    /// This is used in combination with NetSwitch and SwIn[] or SwOut[] to produce the full universe address.
    public var subSwitch: ArtNet.PortAddress.SubNet
    
    /// The Oem word describes the equipment vendor and the feature set available.
    /// Bit 15 high indicates extended features available.
    public var oem: OEMCode
    
    /// Ubea Version
    ///
    /// This field contains the firmware version of the User Bios Extension Area (UBEA).
    /// If the UBEA is not programmed, this field contains zero.
    public var ubeaVersion: UInt8
    
    /// General Status register
    public var status1: BitMaskOptionSet<Status1>
    
    /// The ESTA manufacturer code.
    ///
    /// These codes are used to represent equipment manufacturer.
    /// They are assigned by ESTA.
    /// This field can be interpreted as two ASCII bytes representing the manufacturer initials.
    public var estaCode: ESTACode
    
    /// The array represents a null terminated short name for the Node.
    ///
    /// The Controller uses the ArtAddress packet to program this string.
    /// Max length is 17 characters plus the null. This is a fixed length field, although the string it contains can be shorter than the field.
    public var shortName: String
    
    /// The array represents a null terminated long name for the Node.
    ///
    /// The Controller uses the ArtAddress packet to program this string.
    /// Max length is 63 characters plus the null. This is a fixed length field, although the string it contains can be shorter than the field.
    public var longName: String
    
    /// The array is a textual report of the Node’s operating status or operational errors.
    ///
    /// It is primarily intended for ‘engineering’ data rather than ‘end user’ data. The field is formatted as: “#xxxx [yyyy..] zzzzz...”
    /// xxxx is a hex status code. yyyy is a decimal counter that increments every time the Node sends an ArtPollResponse.
    /// This allows the controller to monitor event changes in the Node.
    /// zzzz is an English text string defining the status.
    /// This is a fixed length field, although the string it contains can be shorter than the field.
    public var nodeReport: String
    
    /// Number of input or output ports.
    ///
    /// If number of inputs is not equal to number of outputs, the largest value is taken.
    /// Zero is a legal value if no input or output ports are implemented. The maximum value is 4.
    /// Nodes can ignore this field as the information is implicit in PortTypes[].
    public var ports: UInt16
    
    /// This array defines the operation and protocol of each channel.
    ///
    /// A product with 4 inputs and 4 outputs would report `0xc0, 0xc0, 0xc0, 0xc0`.
    public var portTypes: ChannelArray<Channel>
    
    /// This array defines input status of the node.
    public var inputStatus: ChannelArray<BitMaskOptionSet<InputStatus>>
    
    /// This array defines output status of the node.
    public var outputStatus: ChannelArray<BitMaskOptionSet<OutputStatus>>
    
    /// Bits 3-0 of the 15 bit Port-Address for each of the 4 possible input ports are encoded into the low nibble.
    public var inputAddresses: ChannelArray<PortAddress>
    
    /// Bits 3-0 of the 15 bit Port-Address for each of the 4 possible output ports are encoded into the low nibble.
    public var outputAddresses: ChannelArray<PortAddress>
    
    /// Set to 00 when video display is showing local data. Set to 01 when video is showing ethernet data. The field is now deprecated.
    public let video: Bool
    
    /// If the Node supports macro key inputs, this byte represents the trigger values.
    /// The Node is responsible for ‘debouncing’ inputs. When the ArtPollReply is set to transmit automatically,
    /// (TalkToMe Bit 1), the ArtPollReply will be sent on both key down and key up events.
    /// However, the Controller should not assume that only one bit position has changed.
    /// The Macro inputs are used for remote event triggering or cueing.
    /// Bit fields are active high.
    public var macro: BinaryArray
    
    /// If the Node supports remote trigger inputs, this byte represents the trigger values.
    /// The Node is responsible for ‘debouncing’ inputs. When the ArtPollReply is set to transmit automatically, (TalkToMe Bit 1),
    /// the ArtPollReply will be sent on both key down and key up events.
    /// However, the Controller should not assume that only one bit position has changed.
    /// The Remote inputs are used for remote event triggering or cueing.
    /// Bit fields are active high.
    public var remote: BinaryArray
    
    /// Not used, set to zero
    internal let spare1: UInt8
    
    /// Not used, set to zero
    internal let spare2: UInt8
    
    /// Not used, set to zero
    internal let spare3: UInt8
    
    /// The Style code defines the equipment style of the device.
    public var style: Style
    
    /// MAC Address
    public var macAddress: MacAddress
    
    /// If this unit is part of a larger or modular product, this is the IP of the root device.
    public var bindAddress: NetworkAddress.IPv4
    
    /// This number represents the order of bound devices. A lower number means closer to root device. A value of 1 means root device.
    public var bindIndex: UInt8
    
    /// General Status register 2
    public var status2: BitMaskOptionSet<Status2>
    
    /// Transmit as zero. For future expansion.
    internal let filler: Data
    
    // MARK: - Initialization
    
    public init(address: NetworkAddress.IPv4,
                firmwareVersion: UInt16 = 0,
                netSwitch: ArtNet.PortAddress.Net = 0,
                subSwitch: ArtNet.PortAddress.SubNet = 0,
                oem: OEMCode,
                ubeaVersion: UInt8 = 0,
                status1: BitMaskOptionSet<Status1> = [],
                estaCode: ESTACode = 0x00,
                shortName: String,
                longName: String,
                nodeReport: String,
                ports: UInt16 = 0,
                portTypes: ChannelArray<Channel> = [],
                inputStatus: ChannelArray<BitMaskOptionSet<InputStatus>> = [],
                outputStatus: ChannelArray<BitMaskOptionSet<OutputStatus>> = [],
                inputAddresses: ChannelArray<PortAddress> = [],
                outputAddresses: ChannelArray<PortAddress> = [],
                macro: BinaryArray = false,
                remote: BinaryArray = false,
                style: Style = .node,
                macAddress: MacAddress,
                bindAddress: NetworkAddress.IPv4 = .zero,
                bindIndex: UInt8 = 0,
                status2: BitMaskOptionSet<Status2> = []) {
        
        self.address = address
        self.firmwareVersion = firmwareVersion
        self.netSwitch = netSwitch
        self.subSwitch = subSwitch
        self.oem = oem
        self.ubeaVersion = ubeaVersion
        self.status1 = status1
        self.estaCode = estaCode
        self.shortName = shortName
        self.longName = longName
        self.nodeReport = nodeReport
        self.ports = ports
        self.portTypes = portTypes
        self.inputStatus = inputStatus
        self.outputStatus = outputStatus
        self.inputAddresses = inputAddresses
        self.outputAddresses = outputAddresses
        self.macro = macro
        self.remote = remote
        self.style = style
        self.macAddress = macAddress
        self.bindAddress = bindAddress
        self.bindIndex = bindIndex
        self.status2 = status2
        self.port = 0x1936
        self.video = false
        self.spare1 = 0
        self.spare2 = 0
        self.spare3 = 0
        self.filler = Data(repeating: 0x00, count: 26)
    }
}

// MARK: - Supporting Types

// MARK: - Status1

public extension ArtPollReply {
    
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
        
        public static var indicatorNormal: BitMaskOptionSet<Status1> {
            return [.indicatorIdentify, .indicatorMute]
        }
    }
}

// MARK: - Status2

public extension ArtPollReply {
    
    enum Status2: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Product supports web browser configuration.
        case webConfiguration       = 0b00000001
        
        /// Node’s IP is DHCP configured.
        case dhcpConfigured         = 0b00000010
        
        /// Node is DHCP capable.
        case dhcpCapable            = 0b00000100
        
        /// Node supports 15 bit Port-Address (Art-Net 3 or 4).
        ///
        /// if not set, then node supports 8 bit Port-Address (Art- Net II).
        case portAddress15bit       = 0b00001000
        
        /// Node is able to switch between Art-Net and sACN.
        case sACN                   = 0b00010000
        
        /// Squawking
        case squawking              = 0b00100000
    }
}

// MARK: - Channel

public extension ArtPollReply {
    
    struct Channel: RawRepresentable, Codable, Equatable, Hashable {
        
        public private(set) var rawValue: UInt8
        
        public init(rawValue: UInt8 = 0) {
            self.rawValue = rawValue
        }
    }
}

public extension ArtPollReply.Channel {
    
    /// Channel Protocol type
    var channelProtocol: ArtPollReply.ChannelProtocol {
        get { return ArtPollReply.ChannelProtocol(rawValue: rawValue & 0b00111111) ?? .dmx512 }
        set { rawValue = (rawValue & 0b11000000) + newValue.rawValue }
    }
    
    /// Whether this channel can input onto the Art-Net Network.
    var input: Bool {
        get { return contains(Feature.input) }
        set { newValue ? rawValue.insert(Feature.input) : rawValue.remove(Feature.input) }
    }
    
    /// Whether this channel can output data from the Art-Net Network.
    var output: Bool {
        get { return contains(Feature.output) }
        set { newValue ? rawValue.insert(Feature.output) : rawValue.remove(Feature.output) }
    }
    
    init(channelProtocol: ArtPollReply.ChannelProtocol,
         input: Bool = false,
         output: Bool = false) {
        
        self.init()
        self.channelProtocol = channelProtocol
        self.input = input
        self.output = output
    }
}

internal extension ArtPollReply.Channel {
    
    enum Feature: UInt8 {
        case input      = 0b01000000
        case output     = 0b10000000
    }
}

// MARK: CustomStringConvertible

extension ArtPollReply.Channel: CustomStringConvertible {
    
    public var description: String {
        return "\(ArtPollReply.self)(channelProtocol: \(channelProtocol), input: \(input), output: \(output))"
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension ArtPollReply.Channel: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

// MARK: - ChannelProtocol

public extension ArtPollReply {
    
    /// Defines the protocol for a channel.
    enum ChannelProtocol: UInt8 {
        
        /// DMX512
        case dmx512     = 0b000000
        
        /// MIDI
        case midi       = 0b000001
        
        /// Avab
        case avab       = 0b000010
        
        /// Colortran CMX
        case cmx        = 0b000011
        
        /// ADB 62.5
        case adb        = 0b000100
        
        /// Art-Net
        case artNet     = 0b000101
    }
}

// MARK: CustomStringConvertible

extension ArtPollReply.ChannelProtocol: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .dmx512:   return "DMX512"
        case .midi:     return "MIDI"
        case .avab:     return "Avab"
        case .cmx:      return "Colortran CMX"
        case .adb:      return "ADB 62.5"
        case .artNet:   return "Art-Net"
        }
    }
}

// MARK: - InputStatus

public extension ArtPollReply {
    
    /// Defines input status of the node.
    enum InputStatus: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Receive errors detected.
        case errorDetected      = 0b00000100
        
        /// Input is disabled.
        case disabled           = 0b00001000
        
        /// Channel includes DMX512 text packets.
        case text               = 0b00010000
        
        /// Channel includes DMX512 SIP’s.
        case sip                = 0b00100000
        
        /// Channel includes DMX512 test packets.
        case test               = 0b01000000
        
        /// Data received.
        case dataRecieved       = 0b10000000
    }
}

// MARK: - OutputStatus

public extension ArtPollReply {
    
    enum OutputStatus: UInt8, Codable, CaseIterable, BitMaskOption {
        
        /// Output is selected to transmit sACN.
        ///
        /// If not set then Output is selected to transmit Art-Net.
        case sACN               = 0b00000001
        
        /// Merge Mode is LTP.
        case ltp                = 0b00000010
        
        /// DMX output short detected on power up
        case shortDetected      = 0b00000100
        
        /// Output is merging ArtNet data.
        case merging            = 0b00001000
        
        /// Channel includes DMX512 text packets.
        case text               = 0b00010000
        
        /// Channel includes DMX512 SIP’s.
        case sip                = 0b00100000
        
        /// Channel includes DMX512 test packets.
        case test               = 0b01000000
        
        /// Data is being transmitted.
        case dataTransmitted    = 0b10000000
    }
}

// MARK: - PortAddress

public extension ArtPollReply {
    
    struct PortAddress: RawRepresentable, Codable, Equatable, Hashable {
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: CustomStringConvertible

extension ArtPollReply.PortAddress: CustomStringConvertible {
    
    public var description: String {
        return "0x" + rawValue.toHexadecimal()
    }
}

// MARK: ExpressibleByIntegerLiteral

extension ArtPollReply.PortAddress: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}
