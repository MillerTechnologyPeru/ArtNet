//
//  PortAddress.swift
//  
//
//  Created by Alsey Coleman Miller on 2/25/20.
//

/**
 The Port-Address of each DMX512 Universe encoded as a 15-bit number.
 
 The high byte is called the 'Net'. This was introduced at Art-Net 3 and was previously zero. The Net has a single value for each node. The high nibble of the low byte is referred to as the Sub-Net address and is set to a single value for each Node. The low nibble of the low byte is used to define the individual DMX512 Universe within the Node.
 This means that any Node will have:
 - One “Net” switch.
 - One “Sub-Net” switch.
 - One “Universe” switch for each implemented DMX512 input or output.
 A product designer may opt to implement these as hard or soft switches.
 */
public struct PortAddress: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt16
    
    public init?(rawValue: UInt16) {
        guard PortAddress.validate(rawValue) else { return nil }
        self.rawValue = rawValue
    }
    
    internal init(unsafe rawValue: UInt16) {
        assert(PortAddress.validate(rawValue), "Must be 15-bit number")
        self.rawValue = rawValue
    }
}

public extension PortAddress {
    
    static var zero: PortAddress { return 0x00 as PortAddress }
    
    static var min: PortAddress { return .zero }
    
    static var max: PortAddress { return 0b0111111111111111 as PortAddress }
}

public extension PortAddress {
    
    /// Bits 3-0
    var universe: Universe {
        return .init(unsafe: UInt8(rawValue & 0x000F))
    }
    
    /// Bits 7-4
    var subnet: SubNet {
        return .init(unsafe: UInt8(rawValue & 0x00F0) >> 4)
    }
    
    /// Bits 14-8
    var net: Net {
        return .init(unsafe: UInt8(rawValue >> 8))
    }
    
    /// Initialize with the specified Universe, Subnet and Net.
    init(universe: Universe, subnet: SubNet, net: Net) {
        var value: UInt16 = 0
        value += UInt16(universe.rawValue)
        value += UInt16(subnet.rawValue) << 4
        value += UInt16(net.rawValue) << 8
        self.init(unsafe: value)
        assert(self.universe == universe)
        assert(self.subnet == subnet)
        assert(self.net == net)
    }
}

internal extension PortAddress {
    
    /// Verify the value is 15-bits
    static func validate(_ rawValue: UInt16) -> Bool {
        return rawValue >> 15 == 0
    }
}

// MARK: - CustomStringConvertible

extension PortAddress: CustomStringConvertible {
    
    public var description: String {
        return "\(type(of: self))(universe: \(universe), subnet: \(subnet), net: \(net))"
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension PortAddress: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(unsafe: value)
    }
}

// MARK: - Supporting Types

// MARK: - Universe

public extension PortAddress {
    
    /// 4-bit Universe nibble
    struct Universe: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt8
        
        public init?(rawValue: UInt8) {
            guard PortAddress.Universe.validate(rawValue) else { return nil }
            self.rawValue = rawValue
        }
        
        internal init(unsafe rawValue: UInt8) {
            assert(PortAddress.Universe.validate(rawValue), "Must be 4-bit number")
            self.rawValue = rawValue
        }
    }
}

internal extension PortAddress.Universe {
    
    /// Verify the value is 4-bits
    static func validate(_ rawValue: UInt8) -> Bool {
        return rawValue >> 4 == 0
    }
}

// MARK: CustomStringConvertible

extension PortAddress.Universe: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.Universe: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(unsafe: value)
    }
}

// MARK: - SubNet

public extension PortAddress {
    
    /// 4-bit Sub-Net
    struct SubNet: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt8
        
        public init?(rawValue: UInt8) {
            guard PortAddress.SubNet.validate(rawValue) else { return nil }
            self.rawValue = rawValue
        }
        
        internal init(unsafe rawValue: UInt8) {
            assert(PortAddress.SubNet.validate(rawValue), "Must be 4-bit number")
            self.rawValue = rawValue
        }
    }
}

internal extension PortAddress.SubNet {
    
    /// Verify the value is 4-bits
    static func validate(_ rawValue: UInt8) -> Bool {
        return rawValue >> 4 == 0
    }
}

// MARK: CustomStringConvertible

extension PortAddress.SubNet: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.SubNet: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(unsafe: value)
    }
}

// MARK: - Net

public extension PortAddress {
    
    /// 7-bit Net
    struct Net: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt8
        
        public init?(rawValue: UInt8) {
            guard PortAddress.Net.validate(rawValue) else { return nil }
            self.rawValue = rawValue
        }
        
        internal init(unsafe rawValue: UInt8) {
            assert(PortAddress.Net.validate(rawValue), "Must be 7-bit number")
            self.rawValue = rawValue
        }
    }
}

internal extension PortAddress.Net {
    
    /// Verify the value is 7-bits
    static func validate(_ rawValue: UInt8) -> Bool {
        return rawValue >> 7 == 0
    }
}

// MARK: CustomStringConvertible

extension PortAddress.Net: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.Net: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(unsafe: value)
    }
}

// MARK: - Address

public struct Address: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public extension Address {
    
    var universe: PortAddress.Universe {
        return PortAddress.Universe(unsafe: rawValue & 0x0F)
    }
    
    var subnet: PortAddress.SubNet {
        return PortAddress.SubNet(unsafe: rawValue >> 4)
    }
    
    init(universe: PortAddress.Universe, subnet: PortAddress.SubNet) {
        self.init(rawValue: universe.rawValue + (subnet.rawValue << 4))
        assert(self.universe == universe)
        assert(self.subnet == subnet)
    }
}

// MARK: CustomStringConvertible

extension Address: CustomStringConvertible {
    
    public var description: String {
        return "\(type(of: self))(universe: \(universe), subnet: \(subnet))"
    }
}

// MARK: ExpressibleByIntegerLiteral

extension Address: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}
