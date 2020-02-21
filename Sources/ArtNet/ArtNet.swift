/**
 Art-Net is an Ethernet protocol based on the TCP/IP protocol suite.
 
 Its purpose is to allow transfer of large amounts of DMX512 data over a wide area using standard networking technology.
 
 - SeeAlso: [Art-Net User Guide](https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf)
 */
public protocol ArtNetPacket {
    
    /// The opcode of the packet.
    static var opCode: OpCode { get }
    
    /// Formatting options for encoding.
    static var formatting: ArtNetFormatting { get }
}

public extension ArtNetPacket {
    
    static var formatting: ArtNetFormatting { .init() }
}
