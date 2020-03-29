//
//  ArtSync.swift
//  
//
//  Created by Jorge Loc Rubio on 3/18/20.
//

import Foundation

/**
   The ArtSync packet can be used to force nodes to synchronously output ArtDmx packets to their outputs.
   This is useful in video and media-wall applications.
 
   A controller that wishes to implement synchronous transmission will unicast multiple universes of ArtDmx and then broadcast an ArtSync to synchronously transfer all the ArtDmx packets to the nodes' outputs at the same time.
*/
public struct ArtSync : ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .sync }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Transmit as zero
    internal let aux1: UInt8
    
    /// Transmit as zero
    internal let aux2: UInt8
    
    // MARK: - Initialization
    
    init() {
        self.protocolVersion = .current
        self.aux1 = 0
        self.aux2 = 0
    }
}
