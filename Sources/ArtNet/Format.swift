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
    
    /// Encode string properties with the specified formatting.
    public var string: [Key: StringFormatting]
    
    public init(littleEndian: [Key] = [],
                data: [Key: DataFormatting] = [:],
                string: [Key: StringFormatting] = [:]) {
        
        self.littleEndian = littleEndian
        self.data = data
        self.string = string
    }
}

public extension ArtNetFormatting {
    
    init <T> (littleEndian: [T] = [],
              data: [T: DataFormatting] = [:],
              string: [T: StringFormatting] = [:]) where T: CodingKey, T: Hashable {
        
        self.littleEndian = littleEndian.map { .init($0) }
        self.data = data.mapKeys { .init($0) }
        self.string = string.mapKeys { .init($0) }
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
    
    init(_ key: CodingKey) {
        self.rawValue = key.stringValue
    }
}

public extension ArtNetFormatting {
    
    /// Formatting options for Data
    enum DataFormatting {
        
        /// The data is prefixed by a 16 bit length specifier.
        case lengthSpecifier
        
        /// The remaining bytes are treated as data.
        case remainder
    }
}

public extension ArtNetFormatting {
    
    enum StringFormatting {
        
        /// Null terminated variable length string
        case variableLength
        
        /// Null terminated fixed length string
        case fixedLength(Int)
    }
}
