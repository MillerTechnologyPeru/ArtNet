//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/22/20.
//

/**
 The ESTA manufacturer code.
 
 These codes are used to represent equipment manufacturer.
 They are assigned by ESTA.
 Can be interpreted as two ASCII bytes representing the manufacturer initials.
 */
public struct ESTACode: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension ESTACode: CustomStringConvertible {
    
    public var description: String {
        return "0x" + rawValue.toHexadecimal()
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension ESTACode: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}
