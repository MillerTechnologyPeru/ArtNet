//
//  ArtTodRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 2/24/20.
//

import Foundation

/**
 This packet is used to request the Table of RDM Devices (TOD). A Node receiving this packet must not interpret it as forcing full discovery.
 Full discovery is only initiated at power on or when an ArtTodControl.AtcFlush is received. The response is ArtTodData.
 */
public struct ArtTodRequest: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .todRequest }
    
    /// Art-Net formatting
    public static let formatting = ArtNetFormatting()
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare1: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare3: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare4: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare5: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare6: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare7: UInt8
    
    /// The top 7 bits of the 15 bit Port-Address of Nodes that must respond to this packet.
    public var net: PortAddress.Net
    
    /// Command
    public var command: Command
    
    /// The number of entries in Address that are used. Max value is 32.
    //public var addCount: UInt8
    
    /// This array defines the low byte of the Port-Address of the Output Gateway nodes that must respond to this packet.
    /// The high nibble is the Sub-Net switch. The low nibble corresponds to the Universe.
    /// This is combined with the 'Net' field above to form the 15 bit address.
    public var addresses: AddressArray
    
    public init(net: PortAddress.Net,
                command: Command = .todFull,
                addresses: AddressArray = []) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.spare1 = 0
        self.spare2 = 0
        self.spare3 = 0
        self.spare4 = 0
        self.spare5 = 0
        self.spare6 = 0
        self.spare7 = 0
        self.net = net
        self.command = command
        self.addresses = addresses
    }
}

public extension ArtTodRequest {
    
    /// The array of Port-Address of the Output Gateway nodes that must respond to this packet.
    var portAddresses: [PortAddress] {
        fatalError() // FIXME:
    }
}

// MARK: - Supporting Types

// MARK: - Command

public extension ArtTodRequest {
    
    /// Command
    enum Command: UInt8, Codable {
        
        /// Send the entire TOD.
        case todFull = 0x00
    }
}

// MARK: - AddressArray

public extension ArtTodRequest {
    
    /// This array defines the low byte of the Port-Address of the Output Gateway nodes that must respond to this packet.
    /// The high nibble is the Sub-Net switch. The low nibble corresponds to the Universe.
    /// This is combined with the 'Net' field above to form the 15 bit address.
    struct AddressArray {
        
        // MARK: Properties
        
        internal private(set) var _count: UInt8
        
        internal private(set) var elements: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        // MARK: - Initialization
        
        public init() {
            _count = 0
            elements = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        }
        
        public init(count: Int) {
            precondition(count <= AddressArray.maxLength)
            assert(count >= 0)
            self.init()
            _count = type(of: self).validating(count: count)
        }
        
        internal init<C>(truncated collection: C) where C: Collection, C.Element == Element {
            self.init()
            _count = type(of: self).validating(count: collection.count)
            collection
                .prefix(count)
                .enumerated()
                .forEach { self[$0.offset] = $0.element }
        }
    }
}

internal extension ArtTodRequest.AddressArray {
    
    static func validating(count: Int) -> UInt8 {
        return numericCast(Swift.max(Swift.min(count, maxLength), 0)) // 0 < x < 32
    }
}

public extension ArtTodRequest.AddressArray {
    
    static var maxLength: Int { return 32 }
}

// MARK: CustomStringConvertible

extension ArtTodRequest.AddressArray: CustomStringConvertible {
    
    public var description: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "(universe: \($1.universe), subnet: \($1.subnet))" }) + "]"
    }
}

// MARK: Equatable

extension ArtTodRequest.AddressArray {
    
    public static func == (lhs: ArtTodRequest.AddressArray, rhs: ArtTodRequest.AddressArray) -> Bool {
        return lhs._count == rhs._count
            && lhs.elements.0 == rhs.elements.0
            && lhs.elements.1 == rhs.elements.1
            && lhs.elements.2 == rhs.elements.2
            && lhs.elements.3 == rhs.elements.3
            && lhs.elements.4 == rhs.elements.4
            && lhs.elements.5 == rhs.elements.5
            && lhs.elements.6 == rhs.elements.6
            && lhs.elements.7 == rhs.elements.7
            && lhs.elements.8 == rhs.elements.8
            && lhs.elements.9 == rhs.elements.9
            && lhs.elements.10 == rhs.elements.10
            && lhs.elements.11 == rhs.elements.11
            && lhs.elements.12 == rhs.elements.12
            && lhs.elements.13 == rhs.elements.13
            && lhs.elements.14 == rhs.elements.14
            && lhs.elements.15 == rhs.elements.15
            && lhs.elements.16 == rhs.elements.16
            && lhs.elements.17 == rhs.elements.17
            && lhs.elements.18 == rhs.elements.18
            && lhs.elements.19 == rhs.elements.19
            && lhs.elements.20 == rhs.elements.20
            && lhs.elements.21 == rhs.elements.21
            && lhs.elements.22 == rhs.elements.22
            && lhs.elements.23 == rhs.elements.23
            && lhs.elements.24 == rhs.elements.24
            && lhs.elements.25 == rhs.elements.25
            && lhs.elements.26 == rhs.elements.26
            && lhs.elements.27 == rhs.elements.27
            && lhs.elements.28 == rhs.elements.28
            && lhs.elements.29 == rhs.elements.29
            && lhs.elements.30 == rhs.elements.30
            && lhs.elements.31 == rhs.elements.31
    }
}

// MARK: Hashable

extension ArtTodRequest.AddressArray: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        forEach { ($0.universe.rawValue + $0.subnet.rawValue).hash(into: &hasher) }
    }
}

// MARK: ExpressibleByArrayLiteral

extension ArtTodRequest.AddressArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: PortAddress...) {
        fatalError()
    }
}

// MARK: Codable

extension ArtTodRequest.AddressArray: Codable {
    
    public init(from decoder: Decoder) throws {
        fatalError()
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
}

// MARK: - ArtNet Codable

extension ArtTodRequest.AddressArray: ArtNetCodable {
    
    public static var artNetLength: Int { return 33 }
    
    public init?(artNet data: Data) {
        guard data.count == type(of: self).artNetLength
            else { return nil }
        let count = data[0]
        guard count <= type(of: self).maxLength
            else { return nil }
        self.init()
        self._count = count
        self.elements = (
            data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10],
            data[11], data[12], data[13], data[14], data[15], data[16], data[17], data[18], data[19], data[20],
            data[21], data[22], data[23], data[24], data[25], data[26], data[27], data[28], data[29], data[30],
            data[31], data[32]
        )
    }
    
    public var artNet: Data {
        return Data([_count, ])
    }
}

// MARK: Sequence

extension ArtTodRequest.AddressArray: Sequence {
    
    public func makeIterator() -> IndexingIterator<Self> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: RandomAccessCollection

extension ArtTodRequest.AddressArray: RandomAccessCollection, MutableCollection {
    
    public var count: Int {
        return numericCast(_count)
    }
    
    public subscript (index: Int) -> (universe: PortAddress.Universe, subnet: PortAddress.SubNet) {
        get {
            assert(index < Int(_count), "Invalid index \(index)")
            let byte: UInt8
            switch index {
            case 0: byte = elements.0
            case 1: byte = elements.1
            case 2: byte = elements.2
            case 3: byte = elements.3
            case 4: byte = elements.4
            case 5: byte = elements.5
            case 6: byte = elements.6
            case 7: byte = elements.7
            case 8: byte = elements.8
            case 9: byte = elements.9
            case 10: byte = elements.10
            case 11: byte = elements.11
            case 12: byte = elements.12
            case 13: byte = elements.13
            case 14: byte = elements.14
            case 15: byte = elements.15
            case 16: byte = elements.16
            case 17: byte = elements.17
            case 18: byte = elements.18
            case 19: byte = elements.19
            case 20: byte = elements.20
            case 21: byte = elements.21
            case 22: byte = elements.22
            case 23: byte = elements.23
            case 24: byte = elements.24
            case 25: byte = elements.25
            case 26: byte = elements.26
            case 27: byte = elements.27
            case 28: byte = elements.28
            case 29: byte = elements.29
            case 30: byte = elements.30
            case 31: byte = elements.31
            default: fatalError("Invalid index \(index)")
            }
            let universe = PortAddress.Universe(rawValue: byte) // FIXME:
            let subnet = PortAddress.SubNet(rawValue: byte)
            return (universe, subnet)
        }
        set {
            fatalError()
        }
    }
    
    public var startIndex: Int {
        return 0
    }
    
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
