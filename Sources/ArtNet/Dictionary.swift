//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

internal extension Dictionary {
    
    func mapKeys <K: Hashable> (_ map: (Self.Key) throws -> (K)) rethrows -> [K: Value] {
        
        var newValue = [K: Value](minimumCapacity: count)
        for (key, value) in self {
            let newKey = try map(key)
            newValue[newKey] = value
        }
        return newValue
    }
}
