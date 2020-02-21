//
//  OpCode.swift
//  
//
//  Created by Alsey Coleman Miller on 2/13/20.
//

/// ArtNet OpCode
public enum OpCode: UInt16, Codable {
    
    /// This is an ArtPoll packet, no other data is contained in this UDP packet.
    case poll                   = 0x2000
    
    /// This is an ArtPollReply Packet. It contains device status information.
    case pollReply              = 0x2100
    
    /// Diagnostics and data logging packet.
    case diagnostics            = 0x2300
    
    /// Used to send text based parameter commands.
    case command                = 0x2400
    
    /// This is an ArtDmx data packet. It contains zero start code DMX512 information for a single Universe.
    case dmx                    = 0x5000
    
    /// This is an ArtNzs data packet. It contains non-zero start code (except RDM) DMX512 information for a single Universe.
    case nzs                    = 0x5100
    
    /// This is an ArtSync data packet. It is used to force synchronous transfer of ArtDmx packets to a node’s output.
    case sync                   = 0x5200
    
    /// This is an ArtAddress packet. It contains remote programming information for a Node.
    case address                = 0x6000
    
    /// This is an ArtInput packet. It contains enable – disable data for DMX inputs.
    case input                  = 0x7000
    
    /// This is an ArtTodRequest packet. It is used to request a Table of Devices (ToD) for RDM discovery.
    case todRequest             = 0x8000
    
    /// This is an ArtTodData packet. It is used to send a Table of Devices (ToD) for RDM discovery.
    case todData                = 0x8100
    
    /// This is an ArtTodControl packet. It is used to send RDM discovery control messages.
    case todControl             = 0x8200
    
    /// This is an ArtRdm packet. It is used to send all non discovery RDM messages.
    case rdm                    = 0x8300
    
    /// This is an ArtRdmSub packet. It is used to send compressed, RDM Sub-Device data.
    case rdmSub                 = 0x8400
    
    /// This is an ArtVideoSetup packet. It contains video screen setup information for nodes that implement the extended video features.
    case videoSetup             = 0xa010
    
    /// This is an ArtVideoPalette packet. It contains colour palette setup information for nodes that implement the extended video features.
    case videoPalette           = 0xa020
    
    /// This is an ArtVideoData packet. It contains display data for nodes that implement the extended video features.
    case videoData              = 0xa040
    
    /// Deprecated packet.
    case macMaster              = 0xf000
    
    /// Deprecated packet.
    case macSlave               = 0xf100
    
    /// This is an ArtFirmwareMaster packet. It is used to upload new firmware or firmware extensions to the Node.
    case firmwareMaster         = 0xf200
    
    /// This is an ArtFirmwareReply packet. It is returned by the node to acknowledge receipt of an ArtFirmwareMaster packet or ArtFileTnMaster packet.
    case firmwareReply          = 0xf300
    
    /// Uploads user file to node.
    case fileUpload             = 0xf400
    
    /// Downloads user file from node.
    case fileDownload           = 0xf500
    
    /// Server to Node acknowledge for download packets.
    case fileDownloadReply      = 0xf600
    
    /// This is an ArtIpProg packet. It is used to re- programme the IP address and Mask of the Node.
    case ipProgram              = 0xf800
    
    /// This is an ArtIpProgReply packet. It is returned by the node to acknowledge receipt of an ArtIpProg packet.
    case ipProgramReply         = 0xf900
    
    /// This is an ArtMedia packet. It is Unicast by a Media Server and acted upon by a Controller.
    case media                  = 0x9000
    
    /// This is an ArtMediaPatch packet. It is Unicast by a Controller and acted upon by a Media Server.
    case mediaPatch             = 0x9100
    
    /// This is an ArtMediaControl packet. It is Unicast by a Controller and acted upon by a Media Server.
    case mediaControl           = 0x9200
    
    /// This is an ArtMediaControlReply packet. It is Unicast by a Media Server and acted upon by a Controller.
    case mediaControlReplay     = 0x9300
    
    /// This is an ArtTimeCode packet. It is used to transport time code over the network.
    case timeCode               = 0x9700
    
    /// Used to synchronise real time date and clock
    case timeSync               = 0x9800
    
    /// Used to send trigger macros
    case trigger                = 0x9900
    
    /// Requests a node's file list
    case directory              = 0x9a00
    
    /// Replies to OpDirectory with file list
    case directoryReply         = 0x9b00
}
