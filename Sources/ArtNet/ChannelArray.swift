//
//  ChannelArray.swift
//  
//
//  Created by Alsey Coleman Miller on 3/18/20.
//

import Foundation

// MARK: - ChannelArray
public struct ChannelArray <T> where T: RawRepresentable, T.RawValue == UInt8, T: Codable, T: Hashable {
    
    internal let elements: (T?, T?, T?, T?)
    
    public init(_ elements: (T?, T?, T?, T?)) {
        self.elements = elements
    }
}

public extension ChannelArray {
    
    init<S>(_ sequence: S) where S: Sequence, S.Element == T {
        let prefix = Array(sequence.prefix(4))
        self.init((prefix.count > 0 ? prefix[0] : nil,
                   prefix.count > 1 ? prefix[1] : nil,
                   prefix.count > 2 ? prefix[2] : nil,
                   prefix.count > 3 ? prefix[3] : nil))
    }
}

internal extension ChannelArray {
    
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        return (elements.0?.rawValue ?? 0,
                elements.1?.rawValue ?? 0,
                elements.2?.rawValue ?? 0,
                elements.3?.rawValue ?? 0)
    }
    
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        self.init((T(rawValue: bytes.0),
                   T(rawValue: bytes.1),
                   T(rawValue: bytes.2),
                   T(rawValue: bytes.3)))
    }
}

// MARK: Equatable

extension ChannelArray: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhs = lhs.bytes
        let rhs = rhs.bytes
        return lhs.0 == rhs.0
            && lhs.1 == rhs.1
            && lhs.2 == rhs.2
            && lhs.3 == rhs.3
    }
}

// MARK: Hashable

extension ChannelArray: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        let bytes = self.bytes
        bytes.0.hash(into: &hasher)
        bytes.1.hash(into: &hasher)
        bytes.2.hash(into: &hasher)
        bytes.3.hash(into: &hasher)
    }
}

// MARK: CustomStringConvertible

extension ChannelArray: CustomStringConvertible {
    
    public var description: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + description(for: $1) }) + "]"
    }
}

private extension ChannelArray {
    
    func description(for element: Element) -> String {
        return element.flatMap { "\($0)" } ?? "0x00"
    }
}

// MARK: ExpressibleByArrayLiteral

extension ChannelArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: Codable

extension ChannelArray: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let array = try [T?].init(from: decoder)
        guard array.count <= 4 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Array cannot have more than 4 items"))
        }
        self.init((array.count > 0 ? array[0] : nil,
                   array.count > 1 ? array[1] : nil,
                   array.count > 2 ? array[2] : nil,
                   array.count > 3 ? array[3] : nil))
    }
    
    public func encode(to encoder: Encoder) throws {
        
        let array = [T?](self)
        try array.encode(to: encoder)
    }
}

// MARK: Sequence

extension ChannelArray: Sequence {
    
    public func makeIterator() -> IndexingIterator<Self> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: RandomAccessCollection

extension ChannelArray: RandomAccessCollection {
    
    public var count: Int {
        return 4
    }
    
    public subscript (index: Int) -> T? {
        switch index {
        case 0: return elements.0
        case 1: return elements.1
        case 2: return elements.2
        case 3: return elements.3
        default: fatalError("Invalid index \(index)")
        }
    }
    
    /// The start `Index`.
    public var startIndex: Int {
        return 0
    }
    
    /// The end `Index`.
    ///
    /// This is the "one-past-the-end" position, and will always be equal to the `count`.
    public var endIndex: Int {
        return count
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}

// MARK: ArtNet Codable

extension ChannelArray: ArtNetCodable {
    
    public init?(artNet data: Data) {
        guard data.count == 4 else { return nil }
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
    
    public var artNet: Data {
        let bytes = self.bytes
        return Data([bytes.0, bytes.1, bytes.2, bytes.3])
    }
    
    public static var artNetLength: Int { return 4 }
}
