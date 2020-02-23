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
    case debug              = 0x0000
    
    /// Power On Tests successful
    case powerOk            = 0x0001
    
    /// Hardware tests failed at Power On
    case powerFail          = 0x0002
    
    /// Last UDP from Node failed due to truncated length, Most likely caused by a collision.
    case truncatedLength    = 0x0003
    
    /// Unable to identify last UDP transmission. Check OpCode and packet length.
    case parseFail          = 0x0004
    
    /// Unable to open Udp Socket in last transmission attempt.
    case udpFail            = 0x0005
    
    /// Confirms that Short Name programming via ArtAddress, was successful.
    case shortNameOk        = 0x0006
    
    /// Confirms that Long Name programming via ArtAddress, was successful.
    case longNameOk         = 0x0007
    
    /// DMX512 receive errors detected.
    case dmxError           = 0x0008
    
    /// Ran out of internal DMX transmit buffers.
    case dmxUdpFull         = 0x0009
    
    /// Ran out of internal DMX Rx buffers.
    case dmxRxFull          = 0x000a
    
    /// Rx Universe switches conflict.
    case switchError        = 0x000b
    
    /// Product configuration does not match firmware.
    case configurationError = 0x000c
    
    /// DMX output short detected. See GoodOutput field.
    case dmxShort           = 0x000d
    
    /// Last attempt to upload new firmware failed.
    case firmwareFail       = 0x000e
    
    /// User changed switch settings when address locked by remote programming. User changes ignored.
    case userFail           = 0x000f
    
    /// Factory reset has occurred.
    case factoryReset       = 0x0010
}
