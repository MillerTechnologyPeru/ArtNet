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
            .shortName: .fixedLength(64)
        ]
    )
    
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
    public var status1: BitMaskOptionSet<Status1>
    
    /// The ESTA manufacturer code.
    ///
    /// These codes are used to represent equipment manufacturer.
    /// They are assigned by ESTA.
    /// This field can be interpreted as two ASCII bytes representing the manufacturer initials.
    public var estaCode: UInt16
    
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
    /// xxxx is a hex status code as defined in Table 3. yyyy is a decimal counter that increments every time the Node sends an ArtPollResponse.
    /// This allows the controller to monitor event changes in the Node.
    /// zzzz is an English text string defining the status.
    /// This is a fixed length field, although the string it contains can be shorter than the field.
    public var nodeReport: String
    
    /// Number of input or output ports.
    ///
    /// If number of inputs is not equal to number of outputs, the largest value is taken.
    /// Zero is a legal value if no input or output ports are implemented. The maximum value is 4.
    /// Nodes can ignore this field as the information is implicit in PortTypes[].
    public var ports: UInt8
    
    /// This array defines the operation and protocol of each channel.
    ///
    /// A product with 4 inputs and 4 outputs would report `0xc0, 0xc0, 0xc0, 0xc0`.
    public var portTypes: ChannelArray<Channel>
    
    /// This array defines input status of the node.
    public var inputStatus: ChannelArray<InputStatus>
    
    /// This array defines output status of the node.
    public var outputStatus: ChannelArray<OutputStatus>
    
    /// Bits 3-0 of the 15 bit Port-Address for each of the 4 possible input ports are encoded into the low nibble.
    public var inputAddresses: ChannelArray<PortAddress>
    
    /// Bits 3-0 of the 15 bit Port-Address for each of the 4 possible output ports are encoded into the low nibble.
    public var outputAddresses: ChannelArray<PortAddress>
    
    /// Set to 00 when video display is showing local data. Set to 01 when video is showing ethernet data. The field is now deprecated.
    @available(*, deprecated)
    public internal(set) var video: Bool
    
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
    internal var spare1: UInt8 = 0
    
    /// Not used, set to zero
    internal var spare2: UInt8 = 0
    
    /// Not used, set to zero
    internal var spare3: UInt8 = 0
    
    /// The Style code defines the equipment style of the device.
    public var style: Style
    
    /// MAC Address
    //public var macAddress:
    
    /// If this unit is part of a larger or modular product, this is the IP of the root device.
    public var bindAddress: Address.IPv4
    
    /// This number represents the order of bound devices. A lower number means closer to root device. A value of 1 means root device.
    public var bindIndex: UInt8
    
    /// Transmit as zero. For future expansion.
    internal private(set) var filler: Data = Data(repeating: 0x00, count: 26)
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
        
        public static let indicatorNormal: BitMaskOptionSet<Status1> = [.indicatorIdentify, .indicatorMute]
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

// MARK: - ChannelArray

public extension ArtPollReply {
    
    struct ChannelArray <T> where T: RawRepresentable, T.RawValue == UInt8, T: Codable, T: Hashable {
        
        internal let elements: (T?, T?, T?, T?)
        
        public init(_ elements: (T?, T?, T?, T?)) {
            self.elements = elements
        }
    }
}

public extension ArtPollReply.ChannelArray {
    
    init<S>(_ sequence: S) where S: Sequence, S.Element == T {
        let prefix = Array(sequence.prefix(4))
        self.init((prefix.count > 0 ? prefix[0] : nil,
                   prefix.count > 1 ? prefix[1] : nil,
                   prefix.count > 2 ? prefix[2] : nil,
                   prefix.count > 3 ? prefix[3] : nil))
    }
}

internal extension ArtPollReply.ChannelArray {
    
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        return (elements.0?.rawValue ?? 0,
                elements.1?.rawValue ?? 0,
                elements.2?.rawValue ?? 0,
                elements.3?.rawValue ?? 0)
    }
    
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        self.init((T(rawValue: bytes.0),
                   T(rawValue: bytes.1),
                   T(rawValue: bytes.2),
                   T(rawValue: bytes.3)))
    }
}

// MARK: Equatable

extension ArtPollReply.ChannelArray: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.elements.0 == rhs.elements.0
            && lhs.elements.1 == rhs.elements.1
            && lhs.elements.2 == rhs.elements.2
            && lhs.elements.3 == rhs.elements.3
    }
}

// MARK: Hashable

extension ArtPollReply.ChannelArray: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        let bytes = self.bytes
        bytes.0.hash(into: &hasher)
        bytes.1.hash(into: &hasher)
        bytes.2.hash(into: &hasher)
        bytes.3.hash(into: &hasher)
    }
}

// MARK: CustomStringConvertible

extension ArtPollReply.ChannelArray: CustomStringConvertible {
    
    public var description: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + description(for: $1) }) + "]"
    }
}

private extension ArtPollReply.ChannelArray {
    
    func description(for element: Element) -> String {
        return element.flatMap { "\($0)" } ?? "0x00"
    }
}

// MARK: ExpressibleByArrayLiteral

extension ArtPollReply.ChannelArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: Codable

extension ArtPollReply.ChannelArray: Codable {
    
    public init(from decoder: Decoder) throws {
        
        fatalError()
    }
    
    public func encode(to encoder: Encoder) throws {
        
        let array = [T?](self)
        try array.encode(to: encoder)
    }
}

// MARK: Sequence

extension ArtPollReply.ChannelArray: Sequence {
    
    public func makeIterator() -> IndexingIterator<Self> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: RandomAccessCollection

extension ArtPollReply.ChannelArray: RandomAccessCollection {
    
    public var count: Int {
        return 4
    }
    
    public subscript (index: Int) -> T? {
        switch index {
        case 0: return elements.0
        case 1: return elements.1
        case 2: return elements.2
        case 3: return elements.3
        default: fatalError("Invalid index \(index)")
        }
    }
    
    /// The start `Index`.
    public var startIndex: Int {
        return 0
    }
    
    /// The end `Index`.
    ///
    /// This is the "one-past-the-end" position, and will always be equal to the `count`.
    public var endIndex: Int {
        return count
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}

// MARK: ArtNet Codable

extension ArtPollReply.ChannelArray: ArtNetCodable {
    
    public init?(artNet data: Data) {
        guard data.count == 4 else { return nil }
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
    
    public var artNet: Data {
        let bytes = self.bytes
        return Data([bytes.0, bytes.1, bytes.2, bytes.3])
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
    
    var channelProtocol: ArtPollReply.ChannelProtocol {
        get { return ArtPollReply.ChannelProtocol(rawValue: rawValue & 0b00111111) ?? .dmx512 }
        set { rawValue = (rawValue & 0b11000000) + newValue.rawValue }
    }
    
    /// Whether this channel can input onto the Art-Net Network.
    var input: Bool {
        get { return contains(Feature.input) }
        set { newValue ? insert(Feature.input) : remove(Feature.input) }
    }
    
    /// Whether this channel can output data from the Art-Net Network.
    var output: Bool {
        get { return contains(Feature.output) }
        set { newValue ? insert(Feature.output) : remove(Feature.output) }
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

private extension ArtPollReply.Channel {
    
    mutating func insert<T>(_ option: T) where T: RawRepresentable, T.RawValue == UInt8 {
        self.rawValue = self.rawValue | option.rawValue
    }
    
    mutating func remove<T>(_ element: T) where T: RawRepresentable, T.RawValue == UInt8 {
        self.rawValue = self.rawValue & ~element.rawValue
    }
}

// MARK: CustomStringConvertible

extension ArtPollReply.Channel: CustomStringConvertible {
    
    public var description: String {
        return "\(ArtPollReply.self)(channelProtocol: \(channelProtocol), input: \(input), output: \(output))"
    }
}

// MARK: - ChannelProtocol

public extension ArtPollReply {
    
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
