//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 1/29/20.
//

/// The OEM Code or Own Equipment Manufacturer Code is a 16-bit number that uniquely identifies an Art-Net product.
///
/// - Note: OEM Codes are administered by Artistic Licence.
/// - SeeAlso: [Art-Net OEM Code listing](https://art-net.org.uk/join-the-club/oem-code-listing/)
public struct OEMCode: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension OEMCode: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension OEMCode: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue.description //name ?? rawValue.description
    }
}
