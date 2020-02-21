//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

/// ArtNet Encoding Options
public struct ArtNetFormatting {
    
    /// Properties that are little endian numeric values.
    public var littleEndian: [Key]
    
    /// Encode the data properties with the specified formatting.
    public var data: [Key: DataFormatting]
    
    public init(littleEndian: [Key] = [],
                data: [Key: DataFormatting] = [:]) {
        
        self.littleEndian = littleEndian
        self.data = data
    }
}

public extension ArtNetFormatting {
    
    init <T> (littleEndian: [T] = [],
              data: [T: DataFormatting] = [:]) where T: CodingKey, T: Hashable {
        
        self.littleEndian = littleEndian.map { .init($0) }
        self.data = data.mapKeys { .init($0) }
    }
}

// MARK: - Supporting Types

public extension ArtNetFormatting {
    
    /// Type-erased coding key.
    struct Key: RawRepresentable, Equatable, Hashable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public extension ArtNetFormatting.Key {
    
    init <T: CodingKey> (_ key: T) {
        self.rawValue = key.stringValue
    }
}

public extension ArtNetFormatting {
    
    /// Formatting options for Data
    enum DataFormatting {
        
        /// The data is prefixed by a little endian 16 bit length specifier
        case lengthSpecifier
        
        /// The remaining bytes are treated as data.
        case remainder
    }
}
