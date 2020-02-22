//
//  RawRepresentable.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

internal extension RawRepresentable where RawValue: FixedWidthInteger, RawValue: UnsignedInteger {
    
    func contains<T>(_ option: T) -> Bool where T: RawRepresentable, T.RawValue == RawValue {
        return (self.rawValue & option.rawValue) != 0
    }
}

internal extension FixedWidthInteger {
    
    mutating func insert<T>(_ option: T) where T: RawRepresentable, T.RawValue == Self {
        self |= option.rawValue
    }
    
    mutating func remove<T>(_ option: T) where T: RawRepresentable, T.RawValue == Self {
        self &= ~option.rawValue
    }
}
