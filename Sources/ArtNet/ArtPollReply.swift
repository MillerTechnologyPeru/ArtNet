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
    public var status1: Status1
    
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
    
    /// Defines the operation and protocol of each channel. (
    ///
    /// A product with 4 inputs and 4 outputs would report `0xc0, 0xc0, 0xc0, 0xc0`.
    public var portTypes: ChannelArray<Channel>
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

// MARK: - ChannelArray

public extension ArtPollReply {
    
    struct ChannelArray <T> where T: RawRepresentable, T.RawValue == UInt8, T: Codable, T: Hashable {
        
        internal let elements: (T?, T?, T?, T?)
        
        public init(_ elements: (T?, T?, T?, T?)) {
            self.elements = elements
        }
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
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

public extension ArtPollReply.Channel {
    
    var channelProtocol: ArtPollReply.ChannelProtocol {
        get { return ArtPollReply.ChannelProtocol(rawValue: rawValue & 0b00111111) ?? .dmx512 }
        set { self.rawValue = (rawValue & 0b11000000) + newValue.rawValue }
    }
    
    /// Whether this channel can output data from the Art-Net Network.
    var output: Bool {
        get { return contains(Feature.output) }
        set { insert(Feature.output) }
    }
    
    /// Whether this channel can input onto the Art-Net Network.
    var input: Bool {
        get { return contains(Feature.input) }
        set { insert(Feature.input) }
    }
}

internal extension ArtPollReply.Channel {
    
    enum Feature: UInt8 {
        case input      = 0b01000000
        case output     = 0b10000000
    }
}

internal extension ArtPollReply.Channel {
    
    mutating func insert<T>(_ option: T) where T: RawRepresentable, T.RawValue == UInt8 {
        self.rawValue = self.rawValue | option.rawValue
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
