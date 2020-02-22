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
        
        let data = Data([
            0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, // Art-Net
            0x00, 0x20,                                     // Opcode: 0x2000
            0x0E, 0x00,                                     // Protocol version: 14
            0x02,                                           // TalkToMe: Diagnostics (0b01)
            0x10])                                          // Diagnostic: Low (0x10)
        
        do {
            let value = ArtPoll(
                behavior: [.diagnostics],
                priority: .low
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
        
        let value = ArtPollReply(
            address: Address.IPv4(rawValue: "192.168.0.100")!,
            firmwareVersion: 1,
            netSwitch: 0,
            subSwitch: 0,
            oem: 0x28d5,
            ubeaVersion: 0,
            status1: ArtPollReply.Status1.indicatorNormal,
            estaCode: 0,
            shortName: "Short Name",
            longName: "Long Name",
            nodeReport: "",
            ports: 1,
            portTypes: [
                ArtPollReply.Channel(channelProtocol: .artNet, input: true, output: false),
                .init(),
                .init(),
                .init()
            ],
            inputStatus: [[.disabled]],
            outputStatus: [[.dataTransmitted]],
            inputAddresses: [0x01],
            outputAddresses: [0x01],
            macro: [true, false, true],
            remote: [false, true],
            style: .node,
            macAddress: MacAddress(rawValue: "00:1A:7D:DA:71:13")!,
            bindAddress: .zero,
            bindIndex: 0,
            status2: [.dhcpCapable]
        )
        
        XCTAssertEqual(value, value, "Equatable is not working")
        
        do {
            var encoder = ArtNetEncoder()
            encoder.log = { print("Encoder:", $0) }
            let encodedData = try encoder.encode(value)
            
            print(encodedData.hexString)
            print(value)
            
            XCTAssertFalse(encodedData.isEmpty)
            //XCTAssertEqual(encodedData, data)
            
            var decoder = ArtNetDecoder()
            decoder.log = { print("Decoder:", $0) }
            let decodedValue = try decoder.decode(ArtPollReply.self, from: encodedData)
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
