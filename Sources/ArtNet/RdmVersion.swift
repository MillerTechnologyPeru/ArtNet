//
//  RDMVersion.swift
//  
//
//  Created by Jorge Loc Rubio on 3/10/20.
//

import Foundation

/**
    Art-Net Devices that only support RDM DRAFT V1.0 set field to 0x00. Devices that support RDM STANDARD V1.0 set field to 0x01
*/
public enum RdmVersion: UInt8, Codable {
    
    /// RDM DRAFT v1.0
    case draft = 0x00
    
    /// RDM STANDAR v1.0
    case standard = 0x01
}
