//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

/**
 The `NodeReport` code defines generic error, advisory and status messages for both Nodes and Controllers.
 
 The NodeReport is returned in ArtPollReply.
 */
public enum NodeReport: UInt16, CaseIterable, Codable {
    
    /// Booted in debug mode (Only used in development)
    case debug          = 0x0000
    
    /// Power On Tests successful
    case powerOk        = 0x0001
    
    /// Hardware tests failed at Power On
    case powerFail
    
    // TODO: Page 17
}
