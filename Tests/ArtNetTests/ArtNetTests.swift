import XCTest
@testable import ArtNet

final class ArtNetTests: XCTestCase {
    
    static let allTests = [
        ("testID", testID),
        ("testArtPoll", testArtPoll),
        ("testArtPollReply", testArtPollReply)
    ]
    
    func testID() {
        
        let string = "Art-Net"
        let id = ArtNetHeader.ID.artNet
        XCTAssertEqual(id.description, string)
        XCTAssertEqual(id.rawValue, string)
        XCTAssertEqual(id, "Art-Net")
        XCTAssertEqual(id.data, Data([0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00]))
        XCTAssertEqual(id, ArtNetHeader.ID(data: id.data))
    }
    
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
            
            var encoder = ArtNetEncoder()
            encoder.log = { print("Encoder:", $0) }
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            var decoder = ArtNetDecoder()
            decoder.log = { print("Decoder:", $0) }
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
            address: Address.IPv4(rawValue: "192.168.100.113")!,
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
            bindAddress: Address.IPv4(rawValue: "192.168.100.113")!,
            bindIndex: 0,
            status2: [.webConfiguration, .dhcpConfigured, .dhcpCapable] // 0x07, Web configuration supported, DHCP configuration used, DHCP configuration supported, Port-Address size: 8bit
        )
        
        XCTAssertEqual(value.port, 6454)
        XCTAssertEqual(value.video, false)
        XCTAssertEqual(value.filler.count, 26)
        XCTAssertEqual(value, value, "Equatable is not working")
        
        do {
            var encoder = ArtNetEncoder()
            encoder.log = { print("Encoder:", $0) }
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            XCTAssertEqual(encodedData, data)
            
            var decoder = ArtNetDecoder()
            decoder.log = { print("Decoder:", $0) }
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
        
        let portTypes: ArtPollReply.ChannelArray<ArtPollReply.Channel> = [
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
}

// MARK: - Extensions

extension Sequence where Element == UInt8 {
    
    var hexString: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "0x" + $1.toHexadecimal().uppercased() }) + "]"
    }
}
