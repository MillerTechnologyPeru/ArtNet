//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/22/20.
//

public struct BinaryArray: RawRepresentable, Equatable, Hashable {
    
    public var rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension BinaryArray: CustomStringConvertible {
    
    public var description: String {
        return 
    }
}
