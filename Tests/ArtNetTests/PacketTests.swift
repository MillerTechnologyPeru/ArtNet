//
//  PacketTests.swift
//  
//
//  Created by Alsey Coleman Miller on 2/25/20.
//

import Foundation
import XCTest
@testable import ArtNet

final class PacketTests: XCTestCase {
    
    static let allTests = [
        ("testArtPoll", testArtPoll),
        ("testArtPollReply", testArtPollReply),
        ("testArtPollReplyChannel", testArtPollReplyChannel),
        ("testArtDmx", testArtDmx),
        ("testArtTodRequest", testArtTodRequest),
        ("testArtTodControl", testArtTodControl),
        ("testArtRdm", testArtRdm),
        ("testArtTodData",testArtTodData),
        ("testArtRdmSub", testArtRdmSub),
        ("testFirmwareReply", testFirmwareReply),
        ("testArtInput", testArtInput),
        ("testArtNzs", testArtNzs),
        ("testArtSync", testArtSync),
        ("testArtAddress", testArtAddress),
        ("testArtDiagData", testArtDiagData),
        ("testArtTimeCode", testArtTimeCode),
        ("testArtCommand", testArtCommand),
        ("testArtTrigger", testArtTrigger),
        ("testArtIpProg", testArtIpProg),
        ("testFirmwareMaster", testFirmwareMaster),
        ("testArtIpProgReply", testArtIpProgReply),
        ("testArtVlc", testArtVlc),
    ]
    
    lazy var encoder: ArtNetEncoder = {
        var encoder = ArtNetEncoder()
        encoder.log = { print("Encoder:", $0) }
        return encoder
    }()
    
    lazy var decoder: ArtNetDecoder = {
        var decoder = ArtNetDecoder()
        decoder.log = { print("Decoder:", $0) }
        return decoder
    }()
    
    func testArtPoll() {
        
        /**
         Art-Net, Opcode: ArtPoll (0x2000)
         Descriptor Header
             ID: Art-Net
             OpCode: ArtPoll (0x2000)
             ProtVer: 14
         ArtPoll packet
             TalkToMe: 0x02, Send me ArtPollReply on change, Send diagnostics unicast: Broadcast
                 .... ..1. = Send me ArtPollReply on change: Enabled
                 .... .0.. = Send diagnostics messages: Disabled
                 .... 0... = Send diagnostics unicast: Broadcast (0x0)
             Priority: DpAll (0)
         */
        
        let data = Data([
            0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, // Art-Net
            0x00, 0x20,                                     // Opcode: 0x2000
            0x00, 0x0E,                                     // Protocol version: 14
            0x02,                                           // TalkToMe: Diagnostics (0b01)
            0x00                                            // Diagnostic: DpAll (0)
        ])
        
        do {
            let value = ArtPoll(
                behavior: [.diagnostics],
                priority: .all
            )
            
            XCTAssertEqual(value.protocolVersion, .current)
            XCTAssertEqual(value.protocolVersion, 14)
            
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtPoll.self, from: data)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtPollReply() {
        
        /**
         Art-Net, Opcode: ArtPollReply (0x2100)
         Descriptor Header
             ID: Art-Net
             OpCode: ArtPollReply (0x2100)
         ArtPollReply packet
             IP Address: 192.168.100.113
             Port number: 6454
             Version Info: 0x0100
             NetSwitch: 0x01
             SubSwitch: 0x00
             Oem: Artistic Licence:DMX-Hub:4x DMX in,4x DMX out (0x0000)
             UBEA Version: 0
             Status: 0x02, RDM Supported, Port Address Programming Authority: unknown, Indicator State: unknown
             ESTA Code: ESTA (0x0000)
             Short Name: DMXController
             Long Name: DMXController ,ZenController, PCBController or KeyPadController
             Node Report:
             Port Info
                 Number of Ports: 32
                 Port Types
                     Type of Port 1: Art-Net -> DMX512 (0x80)
                     Type of Port 2: DMX512 (0x00)
                     Type of Port 3: DMX512 (0x00)
                     Type of Port 4: DMX512 (0x00)
                 Input Status
                     Input status of Port 1: 0x00
                     Input status of Port 2: 0x00
                     Input status of Port 3: 0x00
                     Input status of Port 4: 0x00
                 Output Status
                     Output status of Port 1: 0x00
                     Output status of Port 2: 0x00
                     Output status of Port 3: 0x00
                     Output status of Port 4: 0x00
                 Input Subswitch
                     Input Subswitch of Port 1: 0x01
                     [Universe of input port 1: 257]
                     Input Subswitch of Port 2: 0x00
                     [Universe of input port 2: 256]
                     Input Subswitch of Port 3: 0x00
                     [Universe of input port 3: 256]
                     Input Subswitch of Port 4: 0x00
                     [Universe of input port 4: 256]
                 Output Subswitch
                     Output Subswitch of Port 1: 0x01
                     [Universe of output port 1: 257]
                     Output Subswitch of Port 2: 0x00
                     [Universe of output port 2: 256]
                     Output Subswitch of Port 3: 0x00
                     [Universe of output port 3: 256]
                     Output Subswitch of Port 4: 0x00
                     [Universe of output port 4: 256]
             SwVideo: Displaying local data (0x00)
             SwMacro: 0x00
             SwRemote: 0x00
             spare: 000000
             Style: StNode (Art-Net to DMX device) (0x00)
             MAC: TexasIns_9a:05:c9 (98:84:e3:9a:05:c9)
             Bind IP Address: 192.168.100.113
             Bind Index: 0x00
             Status2: 0x07, Web configuration supported, DHCP configuration used, DHCP configuration supported, Port-Address size: 8bit Port-Address
                 .... ...1 = Web configuration supported: Supported
                 .... ..1. = DHCP configuration used: Used
                 .... .1.. = DHCP configuration supported: Supported
                 .... 0... = Port-Address size: 8bit Port-Address (0x0)
             filler: 000000000000000000000000000000000000000000000000…
         */
        
        let data = Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x21, 0xC0, 0xA8, 0x64, 0x71, 0x36, 0x19, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x44, 0x4D, 0x58, 0x43, 0x6F, 0x6E, 0x74, 0x72, 0x6F, 0x6C, 0x6C, 0x65, 0x72, 0x20, 0x20, 0x20, 0x20, 0x00, 0x44, 0x4D, 0x58, 0x43, 0x6F, 0x6E, 0x74, 0x72, 0x6F, 0x6C, 0x6C, 0x65, 0x72, 0x20, 0x2C, 0x5A, 0x65, 0x6E, 0x43, 0x6F, 0x6E, 0x74, 0x72, 0x6F, 0x6C, 0x6C, 0x65, 0x72, 0x2C, 0x20, 0x50, 0x43, 0x42, 0x43, 0x6F, 0x6E, 0x74, 0x72, 0x6F, 0x6C, 0x6C, 0x65, 0x72, 0x20, 0x6F, 0x72, 0x20, 0x4B, 0x65, 0x79, 0x50, 0x61, 0x64, 0x43, 0x6F, 0x6E, 0x74, 0x72, 0x6F, 0x6C, 0x6C, 0x65, 0x72, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x98, 0x84, 0xE3, 0x9A, 0x05, 0xC9, 0xC0, 0xA8, 0x64, 0x71, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        XCTAssertEqual(data.count, 239)
        
        let value = ArtPollReply(
            address: NetworkAddress.IPv4(rawValue: "192.168.100.113")!,
            firmwareVersion: 0x0100,
            netSwitch: 0x01,
            subSwitch: 0x00,
            oem: 0x0000, // Artistic Licence:DMX-Hub:4x DMX in,4x DMX out (0x0000)
            ubeaVersion: 0,
            status1: [.rdm], // Status: 0x02, RDM Supported, Port Address Programming Authority: unknown, Indicator State: unknown
            estaCode: 0x0000, // ESTA Code: ESTA (0x0000)
            shortName: "DMXController    ",
            longName: "DMXController ,ZenController, PCBController or KeyPadController",
            nodeReport: "",
            ports: 32, // Number of Ports: 32
            portTypes: [
                .init(channelProtocol: .dmx512, input: false, output: true) // (0x80) Art-Net -> DMX512
            ],
            inputStatus: [],
            outputStatus: [],
            inputAddresses: [0x01], // Input Subswitch of Port 1: 0x01
            outputAddresses: [0x01], // Output Subswitch of Port 1: 0x01
            macro: [],
            remote: [],
            style: .node, // StNode (Art-Net to DMX device) (0x00)
            macAddress: MacAddress(rawValue: "98:84:E3:9A:05:C9")!, // MAC: TexasIns_9a:05:c9
            bindAddress: NetworkAddress.IPv4(rawValue: "192.168.100.113")!,
            bindIndex: 0,
            status2: [.webConfiguration, .dhcpConfigured, .dhcpCapable] // 0x07, Web configuration supported, DHCP configuration used, DHCP configuration supported, Port-Address size: 8bit
        )
        
        XCTAssertEqual(value.port, 6454)
        XCTAssertEqual(value.video, false)
        XCTAssertEqual(value.filler.count, 26)
        XCTAssertEqual(value, value, "Equatable is not working")
        XCTAssertEqual(value.macAddress.hashValue, value.macAddress.hashValue)
        XCTAssertEqual(value.macAddress.description, "98:84:E3:9A:05:C9")
        XCTAssertNotEqual(value.macAddress, .zero)
        XCTAssertNotEqual(value.macAddress, .max)
        XCTAssertNotEqual(value.macAddress, .min)
        
        do {
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtPollReply.self, from: data)
            XCTAssertEqual(decodedValue, value)
            XCTAssertEqual(decodedValue.filler, Data(repeating: 0x00, count: 26), "Invalid filler (\(decodedValue.filler.count) bytes) \(decodedValue.filler.hexString)")
            print("Decoded")
            print(decodedValue)
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtPollReplyChannel() {
        
        let portTypes: ChannelArray<ArtPollReply.Channel> = [
            .init(channelProtocol: .dmx512),
            .init(),
            .init(channelProtocol: .artNet, input: true, output: false)
        ]
        
        portTypes.forEach {
            print("0x" + ($0?.rawValue ?? 0x00).toHexadecimal(), $0?.description ?? "nil")
        }
        
        XCTAssertEqual(portTypes, portTypes, "Equatable is not working")
        
        XCTAssertEqual(portTypes[0]?.channelProtocol, .dmx512)
        XCTAssertEqual(portTypes[0], ArtPollReply.Channel(channelProtocol: .dmx512))
        XCTAssertEqual(portTypes[0]?.input, false)
        XCTAssertEqual(portTypes[0]?.output, false)
        
        XCTAssertEqual(portTypes[1]?.channelProtocol, .dmx512)
        XCTAssertEqual(portTypes[1], ArtPollReply.Channel(channelProtocol: .dmx512))
        XCTAssertEqual(portTypes[1]?.input, false)
        XCTAssertEqual(portTypes[1]?.output, false)
        
        XCTAssertEqual(portTypes[2]?.channelProtocol, .artNet)
        XCTAssertEqual(portTypes[2]?.input, true)
        XCTAssertEqual(portTypes[2]?.output, false)
        
        XCTAssertNil(portTypes[3])
    }
    
    func testArtDmx() {
        
        /**
         Art-Net, Opcode: ArtDMX (0x5000)
         Descriptor Header
             ID: Art-Net
             OpCode: ArtDMX (0x5000)
             ProtVer: 14
         ArtDMX packet
             Sequence: 96
             Physical: 0
             Universe: 257
             Length: 512
         */
        
        let data = Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x60, 0x00, 0x01, 0x01, 0x02, 0x00, 0x00, 0x55, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        XCTAssertEqual(data.count, 530)
        
        /**
         DMX Channels
         0x001:   0% 33% FL  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x011:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x021:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x031:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x041:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x051:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x061:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x071:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x081:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x091:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0a1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0b1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0c1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0d1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0e1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x0f1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x101:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x111:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x121:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x131:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x141:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x151:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x161:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x171:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x181:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x191:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1a1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1b1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1c1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1d1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1e1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         0x1f1:   0%  0%  0%  0%  0%  0%  0%  0%   0%  0%  0%  0%  0%  0%  0%  0%
         */
        
        let lightingData = Data([0x00, 0x55, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        XCTAssertEqual(lightingData.count, 512)
        
        let value = ArtDmx(
            sequence: 96,
            physical: 0,
            portAddress: 257,
            lightingData: lightingData
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        do {
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtDmx.self, from: data)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtTodRequest() {
        
        /**
         Art-Net, Opcode: ArtTodRequest (0x8000)
         Descriptor Header
             ID: Art-Net
             OpCode: ArtTodRequest (0x8000)
             ProtVer: 14
         ArtTodRequest packet
             filler: 0000
             spare: 00000000000000
             Net: 0x00
             Command: TodFull (0x00)
             Address Count: 1
             Address: 01
         Excess Bytes: 000000000000000000000000000000000000000000000000…
         */
        
        let data = Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x80, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let value = ArtTodRequest(net: 0x00, command: .todFull, addresses: [0x01])
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertEqual(value.portAddresses, [0x01])
        XCTAssertEqual(value.addresses, [0x01])
        XCTAssertNotEqual(value.addresses, [])
        XCTAssertEqual(value.addresses, [Address(universe: PortAddress.Universe(rawValue: 1)!, subnet: PortAddress.SubNet(rawValue: 0)!)])
        XCTAssertEqual(value.addresses.hashValue, value.addresses.hashValue)
        XCTAssertNotEqual(value.addresses.hashValue, 0)
        
        do {
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtTodRequest.self, from: data)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtTodControl() {
        
        /**
        Art-Net, Opcode: ArtTodControl (0x8200)
        Descriptor Header
            ID: Art-Net
            OpCode: ArtTodControl (0x8200)
            ProtVer: 14
        ArtTodControl packet
            filler: 0000
            spare: 00000000000000
            Net: 0x00
            Command: None (0x00)
            Address: 00
        */
        
        let data = Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x82, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00])
        
        let value = ArtTodControl(net: 0x01, command: .none, address: 0x00)
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertEqual(value.net, 0x01)
        XCTAssertEqual(value.address, 0x00)
        XCTAssertEqual(value.command, .none)
        XCTAssertNotEqual(value.command, .flush)
        XCTAssertEqual(value.address, Address(universe: value.portAddress.universe, subnet: value.portAddress.subnet))
        
        do {
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtTodControl.self, from: data)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtRdm() {
        
        let data = Data([65, 114, 116, 45, 78, 101, 116, 0, 0, 131, 0, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0])
        
        let value = ArtRdm(
            rdmVersion: .standard,
            net: 0x01,
            command: .process,
            address: 0x01,
            rdmPacket: Data([0x00])
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.net, value.portAddress.net)
        XCTAssertEqual(value.rdmVersion, .standard)
        XCTAssertNotEqual(value.rdmVersion, .draft)
        
        XCTAssertEqual(value.address, Address(universe: value.portAddress.universe, subnet: value.portAddress.subnet))
        XCTAssertEqual(value.command, .process)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtRdm.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtTodData() {
        
        let value = ArtTodData(
            rdmVersion: .standard,
            port: 1,
            bindingIndex: 0,
            net: 1,
            command: .full,
            address: 1,
            uidTotal: 1,
            blockCount: 1,
            devices: [.init(bytes: (0,0,0,0,0,0))]
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.net, value.portAddress.net)
        XCTAssertEqual(value.rdmVersion, .standard)
        XCTAssertNotEqual(value.rdmVersion, .draft)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtTodData.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtRdmSub() {
        
        let value = ArtRdmSub(
            rdmVersion: .standard,
            uid: .max,
            commandClass: .set,
            parameterID: 1,
            subDevice: 0,
            subCount: 1,
            data: Data([0x00, 0x01])
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.commandData, [0x01])
        XCTAssertEqual(value.commandData.count, Int(value.subCount))
        XCTAssertEqual(value.rdmVersion, .standard)
        XCTAssertNotEqual(value.rdmVersion, .draft)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, data)
            
            let decodedValue = try decoder.decode(ArtRdmSub.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testFirmwareReply() {
        
        let value = FirmwareReply(
            statusCode: .allGood
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.statusCode, .allGood)
        XCTAssertNotEqual(value.statusCode, .fail)
        XCTAssertNotEqual(value.statusCode, .blockGood)
        
        XCTAssertEqual(value.spare.count, 21)
        XCTAssertEqual(value.spare, [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(FirmwareReply.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtInput() {
        
        let value = ArtInput(
            bindingIndex: 0x00,
            ports: 0x0000,
            inputs: [.enable, .disable, .init(value: 0x10), .init(value: 0xff)]
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.bindingIndex, 0)
        XCTAssertEqual(value.ports, 0)
        XCTAssertEqual(value.inputs.count, 4)
        XCTAssertEqual(value.inputs, [.enable, .disable, .disable, .disable])
        XCTAssertEqual(value.inputs, [.init(value: 0x00), .init(value: 0xff), .init(value: 0xff), .init(value: 0xff)])
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtInput.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
        
    }
    
    func testArtNzs() {
        
        let lightingData = Data([UInt8](repeating: 0x00, count: 512))
        
        XCTAssertEqual(lightingData.count, 512)
        
        let value = ArtNzs(
            sequence: 0x00,
            startCode: 0xCC,
            portAddress: PortAddress(universe: 0x01, subnet: 0x00, net: 0x01),
            lightingData: lightingData
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        XCTAssertEqual(value.sequence, 0)
        XCTAssertEqual(value.startCode, 204)
        XCTAssertEqual(value.portAddress.net, 1)
        XCTAssertEqual(value.lightingData.count, 512)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtNzs.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtSync() {
        
        let value = ArtSync()
        
        XCTAssertEqual(value.protocolVersion, .current)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtSync.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtAddress() {
        
        let value = ArtAddress(
            netSwitch: 0x01,
            bindingIndex: 0x00,
            shortName: "DMXController    ",
            longName: "DMXController ,ZenController, PCBController or KeyPadController",
            inputAddresses: [0x01],
            outputAddresses: [0x01],
            subSwitch: 0x00,
            video: 0x00,
            command: .none
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertEqual(value.inputAddresses.description, "[0x01, 0x00, 0x00, 0x00]")
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtAddress.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtDiagData() {
        
        let value = DiagnosticData(
            priority: .critical,
            data: Data([0x00])
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertNotEqual(value.priority, .volatile)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(DiagnosticData.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtTimeCode() {
        
        let value = ArtTimeCode(
            frames: .max,
            seconds: .min,
            minutes: .init(integerLiteral: 0xff),
            hours: .init(integerLiteral: 0x3c),
            keyType: .ebu
        )
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertEqual(value.frames, 29)
        XCTAssertEqual(value.seconds, 0)
        XCTAssertEqual(value.minutes, 59)
        XCTAssertEqual(value.hours, 59)
        XCTAssertEqual(value.hours, 0x3b)
        XCTAssertEqual(value.frames, ArtTimeCode.FrameTime.max)
        XCTAssertNotEqual(value.frames, ArtTimeCode.FrameTime.min)
        XCTAssertEqual(value.seconds, ArtTimeCode.Time.min)
        XCTAssertNotEqual(value.seconds, ArtTimeCode.Time.max)
        
        XCTAssertNotEqual(value.keyType, .film)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtTimeCode.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtCommand() {
        
        let value = ArtCommand(
            estaCode: ESTACode(rawValue: 0xffff),
            data: Data([UInt8](repeating: 0x00, count: 512))
        )
        
        XCTAssertEqual(value.data.count, 512)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtCommand.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtTrigger() {
        
        let value = ArtTrigger(
            oem: OEMCode(rawValue: 0xffff),
            key: .undefined,
            subKey: 0,
            payload: []
        )
        
        XCTAssertEqual(value.key, ArtTrigger.TriggerKey(value: 0x05))
        XCTAssertEqual(value.key, ArtTrigger.TriggerKey(value: 0xff))
        XCTAssertNotEqual(value.key, ArtTrigger.TriggerKey(value: 0x00))
        XCTAssertEqual(value.payload.count, 0)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtTrigger.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtIpProg() {
        
        let value = ArtIpProg(
            command: [.setDefault],
            ip: NetworkAddress.IPv4(rawValue: "192.168.0.0")!,
            subnet: SubnetMask.classA
        )
        
        XCTAssertEqual(value.command, [.setDefault])
    
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtIpProg.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testFirmwareMaster() {
        
        let value = FirmwareMaster(
            firmwareType: .firmwareFirst,
            blockId: 0x00,
            firmwareLength: .init(length3: 0x00, length2: 0x00, length1: 0x02, length0: 0x00),
            data: Data([UInt8](repeating: 0x00, count: 1024)))
        
        XCTAssertEqual(value.protocolVersion, .current)
        XCTAssertEqual(value.firmwareType.rawValue, 0x00)
        XCTAssertEqual(value.blockId, 0x00)
        
        dump(value.firmwareLength)
        dump(value.firmwareLength.rawValue)
        
        dump(value.firmwareLength.rawValue.bytes.0)
        dump(value.firmwareLength.rawValue.bytes.1)
        dump(value.firmwareLength.rawValue.bytes.2)
        dump(value.firmwareLength.rawValue.bytes.3)
        
        
        XCTAssertEqual(value.firmwareLength.rawValue, 512)
        XCTAssertEqual(value.firmwareLength, FirmwareMaster.FirmwareLength(rawValue: 512))
        let testData = [UInt16](repeating: 0x00, count: 512)
        XCTAssertEqual(value.firmwareData.count, testData.count)
        XCTAssertEqual(value.firmwareData, [UInt16](repeating: 0x00, count: 512))
        
        XCTAssertNotNil(value.data)
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(FirmwareMaster.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtIpProgReply() {
        
        let value = ArtIpProgReply(
            ip: NetworkAddress.IPv4(rawValue: "192.169.0.1")!,
            subnet: SubnetMask(rawValue: "255.255.255.0")!,
            status: .dhcpEnabled
        )
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtIpProgReply.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
    
    func testArtVlc() {
        
        let value = ArtVlc(
            sequence: 0x00,
            portAddress: PortAddress.init(
                universe: 0x00,
                subnet: 0x00,
                net: 0x01
            ),
            length: 0x07A,
            data: ArtVlc.VlcData(
                flags: [.beacon],
                transaction: 0x0102,
                slotAddress: 0x0304,
                payloadCount: 0x0506,
                payloadChecksum: 0x0708,
                depth: 0x09,
                frequency: 0x0A0B,
                modulation: 0x0C0D,
                languageCode: .beaconText,
                beaconRepeat: 0x0F10,
                payload: Data([UInt8](repeating: 0x00, count: 100))
            )
        )
        
        XCTAssertFalse(value.vlcArrayData.isEmpty)
        dump(value.data)
        dump(value.vlcArrayData)
        
        XCTAssertEqual(value.vlcArrayData.count, Int(value.length))
        
        do {
            let encodedData = try encoder.encode(value)
            print(encodedData.hexString)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, value)
            
            let decodedValue = try decoder.decode(ArtVlc.self, from: encodedData)
            XCTAssertEqual(decodedValue, value)
            
            XCTAssertEqual(decodedValue.vlcArrayData.count, value.vlcArrayData.count)
            XCTAssertEqual(decodedValue.vlcArrayData, value.vlcArrayData)
            
        } catch {
            
            XCTFail(error.localizedDescription)
            dump(error)
        }
    }
}

// MARK: - Extensions

extension Sequence where Element == UInt8 {
    
    var hexString: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "0x" + $1.toHexadecimal().uppercased() }) + "]"
    }
}
