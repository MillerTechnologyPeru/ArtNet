//
//  FirmwareMaster.swift
//  
//
//  Created by Jorge Loc Rubio on 3/20/20.
//

import Foundation

/**
 
*/
public struct FirmwareMaster:  ArtNetPacket, Equatable, Hashable, Codable {
   
   /// ArtNet packet code.
   public static var opCode: OpCode { return .firmwareMaster }
    
    /// Art-Net formatting
    public static let formatting = ArtNetFormatting(
        data: [
            CodingKeys.data: .remainder
        ]
    )
   
    // MARK: - Properties

    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Pad length to match ArtPoll.
    internal let filler1: UInt8
    
    /// Pad length to match ArtPoll.
    internal let filler2: UInt8
    
    /// Defines the packet contents
    public var firmwareType: firmwareType
    
    /// Counts the consecutive blocks of firmware upload.
    /// Stating at `0x00` for the `firmwareFirst` or `ubeaFirst` packet.
    public var blockId: UInt8
    
    /// Firmware length
    public var firmwareLength: FirmwareLength
    
    /// Controller sets to zero, Node does not test.
    internal let spare: [UInt8]
    
    /// This array contains the firmware or UBEA data block.
    /// The interpretation of this data is manufacturer specific.
    /// Final packet should be null packet if less than 512 bytes needed.
    public var data: Data
    
    // MARK: - Initialization
    public init(firmwareType: firmwareType,
                blockId: UInt8,
                firmwareLength: FirmwareLength,
                data: Data) {
        
        self.protocolVersion = .current
        self.filler1 = 0
        self.filler2 = 0
        self.firmwareType = firmwareType
        self.blockId = blockId
        self.firmwareLength = firmwareLength
        self.spare = [UInt8](repeating: 0, count: 20)
        self.data = data
    }
}

public extension FirmwareMaster {
    
    var firmwareData: [UInt16] {
        let size = dataSize
        guard size > 0,
              data.count == size * 2
            else { return [] }
        return (0 ..< size)
            .map { UInt16(bigEndian: UInt16(bytes: (data[$0], data[$0 + 1]))) }
    }
    
    internal var dataSize: Int { return Int(firmwareLength.rawValue) }
}

// MARK: - Supporting Types

// MARK: - Type

public extension FirmwareMaster {
    
    /// FirmwareType
    enum firmwareType: UInt8, Codable {
        
        /// The first packet of a firmware upload.
        case firmwareFirst = 0x00
        
        /// A consecutive continuation packet of a firmware upload.
        case firmwareContinuation = 0x01
        
        /// The last packet of a firmware upload.
        case firmwareLast = 0x02
        
        /// The first packet of a ubea upload.
        case ubeaFirst = 0x03
        
        /// A consecutive continuation packet of a ubea upload.
        case ubeaContinuation = 0x04
        
        /// The last packet of a ubea upload.
        case ubeaLast = 0x05
    }
}

// MARK: - Firmware

/**
    This Int64 parameter describes the total number of words (Int16) in the firmware upload plus the firmware header size.
     Eg a 32K word upload plus 530 words of header information == 0x00008212.
 
    This value is also  the file size (in words) of the file to be uploaded.
 */
public extension FirmwareMaster {
    
    struct FirmwareLength: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        /// - Parameter length0: LSB
        public init(length3: UInt8, length2:UInt8, length1: UInt8, length0: UInt8) {
            self.rawValue = UInt32(bigEndian: UInt32(bytes: (length3, length2, length1, length0)))
        }
    }
}
