//
//  Codable.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

/// Art-Net Codable
public typealias ArtNetCodable = ArtNetEncodable & ArtNetDecodable

/// Art-Net Decodable type
public protocol ArtNetDecodable: Decodable {
    
    init?(artNet data: Data)
    
    static var artNetLength: Int { get }
}

/// Art-Net Encodable type
public protocol ArtNetEncodable: Encodable {
    
    var artNet: Data { get }
}
