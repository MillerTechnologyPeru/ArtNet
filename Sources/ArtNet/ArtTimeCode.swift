//
//  ArtTimeCode.swift
//  
//
//  Created by Jorge Loc Rubio on 3/19/20.
//

import Foundation

/**
    ArtTimeCode allows time code to be transported over the network.
    The data format is compatible with both longitudinal time code and MIDI time code.
    The four key types of Film, EBU, Drop Frame and SMPTE are also encoded.
    
    Use of the packet is application specific but in general a single controller will broadcast the packet to the network
*/
public struct ArtTimeCode: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .timeCode }
    
    // MARK: - Properties
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Ignore by receiver, set to zero by sender..
    internal let filler1: UInt8
    
    /// Ignore by receiver, set to zero by sender..
    internal let filler2: UInt8
    
    /// Frames time. 0 - 29 depending on mode.
    public var frames: FrameTime
    
    /// Seconds. 0 - 59.
    public var seconds: Time
    
    /// Minutes. 0 - 59,
    public var minutes: Time
    
    /// Hours. 0 - 59.
    public var hours: Time
    
    /// Key type
    public var keyType: KeyType
    
    // MARK: - Initialization
    
    public init(frames: FrameTime = .max,
                seconds: Time = .min,
                minutes: Time = .min,
                hours: Time = .min,
                keyType: KeyType) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.frames = frames
        self.seconds = seconds
        self.minutes = minutes
        self.hours = hours
        self.keyType = keyType
    }
}

// MARK: - Supporting Types

// MARK: - Key Type

public extension ArtTimeCode {
    
    /// Key type
    enum KeyType: UInt8, Codable {
        
        /// Film (24fps)
        case film = 0x00
        
        /// EBU (25fps)
        case ebu = 0x01
        
        /// DF (29.97fps)
        case df = 0x02
        
        /// SMPTE (30fps)
        case smpte = 0x03
    }
}

// MARK: - Frame Time
public extension ArtTimeCode {
    
    /// Frame Time
    struct FrameTime: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt8
        
        public init?(rawValue: UInt8) {
            self.rawValue = FrameTime.validate(rawValue)
        }
        
        public init(unsafe rawValue: UInt8) {
            self.rawValue = FrameTime.validate(rawValue)
        }
    }
}

internal extension ArtTimeCode.FrameTime {
    
    /// Validate frame time max value
    static func validate(_ rawValue: UInt8) -> UInt8 {
        return rawValue <= UInt8(0x1d) ? rawValue : UInt8(0x1d)
    }
}

public extension ArtTimeCode.FrameTime {
    
    static var min: ArtTimeCode.FrameTime { return 0x00 as ArtTimeCode.FrameTime }
    static var max: ArtTimeCode.FrameTime { return 0x1d as ArtTimeCode.FrameTime }
}

// MARK:  ExpressibleByIntegerLiteral

extension ArtTimeCode.FrameTime: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(unsafe: value)
    }
}

// MARK: - Time
public extension ArtTimeCode {
    
    /// Time
    struct Time: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt8
        
        public init?(rawValue: UInt8) {
            self.rawValue = Time.validate(rawValue)
        }
        
        public init(unsafe rawValue: UInt8) {
            self.rawValue = Time.validate(rawValue)
        }
    }
}

internal extension ArtTimeCode.Time {
    
    /// Validate time max value
    static func validate(_ rawValue: UInt8) -> UInt8 {
        return rawValue <= UInt8(0x3b) ? rawValue : UInt8(0x3b)
    }
}

public extension ArtTimeCode.Time {
    
    static var min: ArtTimeCode.Time { return 0x00 as ArtTimeCode.Time }
    static var max: ArtTimeCode.Time { return 0x3b as ArtTimeCode.Time }
}

// MARK:  ExpressibleByIntegerLiteral

extension ArtTimeCode.Time: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(unsafe: value)
    }
}
