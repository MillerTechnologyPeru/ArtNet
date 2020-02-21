//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

/// Art-Net protocol revision number
public struct ProtocolVersion: Equatable, Hashable, RawRepresentable, Codable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

public extension ProtocolVersion {
    
    /**
     Current value 14.
     
     - Note: Controllers should ignore communication with nodes using a protocol version lower than 14.
     */
    static var current: ProtocolVersion { return ProtocolVersion(rawValue: 14) }
}

// MARK: - CustomStringConvertible

extension ProtocolVersion: CustomStringConvertible {
    
    public var description: String {
        return rawValue.description
    }
}

// MARK: - ExpressibleByStringLiteral

extension ProtocolVersion: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}
