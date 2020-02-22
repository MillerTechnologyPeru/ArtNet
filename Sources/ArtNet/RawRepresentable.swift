//
//  RawRepresentable.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

internal extension RawRepresentable where RawValue == UInt8 {
    
    func contains<T>(_ option: T) -> Bool where T: RawRepresentable, T.RawValue == UInt8 {
        return (self.rawValue & option.rawValue) != 0
    }
}
