// Art-Net is an Ethernet protocol based on the TCP/IP protocol suite. Its purpose is to allow transfer of large amounts of DMX512 data over a wide area using standard networking technology.
// https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf
public struct ArtNet {
    
    
}

internal extension ArtNet {
    
    /**
     Array of 8 characters, the final character is a null termination.
     Value = ‘A’ ‘r’ ‘t’ ‘-‘ ‘N’ ‘e’ ‘t’ 0x00
     */
    static let id = "Art-Net"
}
