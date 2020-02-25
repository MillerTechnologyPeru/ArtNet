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
    
    public private(set) var rawValue: UInt16
    
    public init?(rawValue: UInt16) {
        guard PortAddress.validate(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

public extension PortAddress {
    
    static var zero: PortAddress { return 0x00 as PortAddress }
}

public extension PortAddress {
    
    /// Bits 3-0
    var universe: Universe {
        get { fatalError() }
        set { fatalError() }
    }
    
    /// Bits 7-4
    var subnet: SubNet {
        get { fatalError() }
        set { fatalError() }
    }
    
    /// Bits 14-8
    var net: Net {
        get { fatalError() }
        set { fatalError() }
    }
    
    init(universe: Universe, subnet: SubNet, net: Net) {
        self = .zero
        self.universe = universe
        self.subnet = subnet
        self.net = net
    }
}

internal extension PortAddress {
    
    /// Verify the value is 15-bits
    static func validate(_ rawValue: UInt16) -> Bool {
        return true // TODO: 15-bit validation
    }
}

// MARK: - CustomStringConvertible

extension PortAddress: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description // TODO: Print address
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension PortAddress: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        assert(PortAddress.validate(value), "Must be 15-bit number")
        self.rawValue = value
    }
}

// MARK: - Supporting Types

// MARK: - Universe

public extension PortAddress {
    
    struct Universe: RawRepresentable, Equatable, Hashable, Codable {
        
        public var rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: CustomStringConvertible

extension PortAddress.Universe: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description // TODO: Print address
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.Universe: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

// MARK: - SubNet

public extension PortAddress {
    
    struct SubNet: RawRepresentable, Equatable, Hashable, Codable {
        
        public var rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: CustomStringConvertible

extension PortAddress.SubNet: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description // TODO: Print address
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.SubNet: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

// MARK: - Net

public extension PortAddress {
    
    struct Net: RawRepresentable, Equatable, Hashable, Codable {
        
        public var rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: CustomStringConvertible

extension PortAddress.Net: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description // TODO: Print address
    }
}

// MARK: ExpressibleByIntegerLiteral

extension PortAddress.Net: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}
