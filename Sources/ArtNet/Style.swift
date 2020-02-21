//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

/**
 The following table details the Style codes.
 The Style code defines the general functionality of a Controller.
 The Style code is returned in ArtPollReply.
 */
public enum Style: UInt8, CaseIterable, Codable {
    
    /// A DMX to / from Art-Net device
    case node           = 0x00
    
    /// A lighting console.
    case controller     = 0x01
    
    /// A Media Server.
    case media          = 0x02
    
    /// A network routing device.
    case route          = 0x03
    
    /// A backup device.
    case backup         = 0x04
    
    /// A configuration or diagnostic tool.
    case configuration  = 0x05
    
    /// A visualiser.
    case visualizer     = 0x06
}

