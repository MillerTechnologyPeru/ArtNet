//
//  ArtTrigger.swift
//  
//
//  Created by Jorge Loc Rubio on 3/20/20.
//

import Foundation

/**
 The ArtTrigger packet is used to send trigger macros to the network.
 The most common implementation involves a single controller broadcasting to all other devices.
 
 In some circumstances a controller may only wish to trigger a single device or a small group in wich case unicast would be used
*/
public struct ArtTrigger: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .trigger }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Ignore by receiver, set to zero by sender.
    internal let filler1: UInt8
    
    /// Ignore by receiver, set to zero by sender.
    internal let filler2: UInt8
    
    /// The manufacturer code of nodes that shall accept this trigger.
    public var oem: OEMCode
    
    /// The Trigger Key.
    public var key: TriggerKey
    
    /// The Trigger SubKey
    public var subKey: UInt8
    
    /// The interpretation of the payload is defined by the Key.
    public var payload: [UInt8]
    
    // MARK: - Initialization
    
    public init(oem: OEMCode,
                key: TriggerKey,
                subKey: UInt8,
                payload: [UInt8]) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.oem = oem
        self.key = key
        self.subKey = subKey
        self.payload = payload
    }
}

// MARK: - Supporting Types

// MARK: - Key

/**
    The Key is a 8-bit number which defines the purpose of the packet.
    The interpretation of this field is depended upon the Oem field.
    If the Oem field is set to a value other than `0xffff` then the Key and SubKey fields are manufacturer specific.
 
    However, when the Oem field = `0xffff` the meaning of the Key, SubKey and Payload is defined by `TriggerKey`
 */
public extension ArtTrigger {
    
    /// TriggerKey
    enum TriggerKey: UInt8, Codable, CaseIterable {
        
        /// The SubKey field contains an SCII character which the receiving device should process as if it were a keyboard press. (Payload not used).
        case ascii = 0x00
        
        /// The Subkey field contains the number of a Macro which the receiving device should execute. (Payload not used).
        case macro = 0x01
        
        /// The SubKey field contains a soft-key number which the receiving device should process as if it were a soft-key keyboard press. (Payload not used).
        case soft = 0x02
        
        /// The SubKey field contains the number of a Show which the receiving device should run. (Payload not used).
        case show = 0x03
        
        /// undefined
        case undefined
        
        init(value: UInt8) {
            if let value = TriggerKey(rawValue: value) {
                self = value
            } else {
                self = .undefined
            }
        }
    }
}
