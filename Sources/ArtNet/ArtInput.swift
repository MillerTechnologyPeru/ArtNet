//
//  ArtInput.swift
//  
//
//  Created by Jorge Loc Rubio on 3/17/20.
//

import Foundation

/**
 A Controller or monitoring device on the network can enable or disable individual DMX512 inputs on any of the network nodes.
 This allows the Controller to directly control network traffic and ensures that unused inputs are disabled and therefore not wasting bandwidth,
 
 All nodes power on with all inputs enabled.
 
 Cautin should be exercised when implementing this function in the controller.
 Keep in mind that some network traffic may be operating on a node to node basis.
*/
public struct ArtInput: ArtNetPacket, Equatable, Hashable, Codable {
    /// ArtNet packet code.
    public static var opCode: OpCode { return .input }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// The BindIndex defines the bound node which originated this packed and is used to uniquely identify the bound node when identical IP addresses are in use..
    
    /// This number represents the order of bound devices.
    
    /// A lower number means closer to root device. A value of 1 means root device.
    public var bindingIndex: UInt8
    
    /// Number of inout or output ports.
    
    /// The high byte is for future expansion and is currently zero.

    /// If number of inputs is not equal to number of outputs, the largest value is taken.

    /// The maximun value is 4
    public var ports: UInt16
    
    /// This Array defines input disable status of each chanel.
    public var inputs: ChannelArray<InputStatus>
    
    // MARK: - Initialization
    
    public init(bindingIndex: UInt8,
                ports: UInt16,
                inputs: ChannelArray<InputStatus> = [.enable, .enable, .enable, .enable]) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.bindingIndex = bindingIndex
        self.ports = 0
        self.inputs = inputs
    }
}

// MARK: - Supporting Types

// MARK: - InputStatus
public extension ArtInput {
    
    enum InputStatus: UInt8, Codable, CaseIterable {
        
        case enable = 0b00000000
        
        case disable = 0b00000001
        
        init(value: UInt8) {
            self = value == 0x00 ? .enable : .disable
        }
    }
}
