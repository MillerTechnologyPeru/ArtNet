//
//  PortAddress.swift
//  
//
//  Created by Alsey Coleman Miller on 2/25/20.
//

/// The Port-Address of each DMX512 Universe encoded as a 15-bit number.
public struct PortAddress: RawRepresentable, Equatable, Hashable, Codable {
    
    public var rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
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
        self.init(rawValue: value)
    }
}
