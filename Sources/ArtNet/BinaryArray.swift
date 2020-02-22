//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 2/22/20.
//

public struct BinaryArray: RawRepresentable, Equatable, Hashable, Codable {
    
    public var rawValue: UInt8
    
    public init(rawValue: UInt8 = 0x00) {
        self.rawValue = rawValue
    }
}

// MARK: - RandomAccessCollection

extension BinaryArray: RandomAccessCollection {
    
    public subscript (index: Int) -> Bool {
        get {
            guard let bit = Bit(index: index)
                else { fatalError("Invalid index \(index)") }
            return contains(bit)
        }
        set {
            guard let bit = Bit(index: index)
                else { fatalError("Invalid index \(index)") }
            newValue ? insert(bit) : remove(bit)
        }
    }
    
    public var isEmpty: Bool {
        return rawValue == 0
    }
    
    public var count: Int {
        return 8
    }
    
    public var startIndex: Int {
        return 0
    }
    
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

private extension BinaryArray {
    
    enum Bit: UInt8, CaseIterable {
        
        case one        = 0b00000001
        case two        = 0b00000010
        case three      = 0b00000100
        case four       = 0b00001000
        case five       = 0b00010000
        case six        = 0b00100000
        case seven      = 0b01000000
        case eight      = 0b10000000
        
        init?(index: Int) {
            switch index {
            case 0: self = .one
            case 1: self = .two
            case 2: self = .three
            case 3: self = .four
            case 4: self = .five
            case 5: self = .six
            case 6: self = .seven
            case 7: self = .eight
            default: return nil
            }
        }
    }
}

private extension BinaryArray {
        
    mutating func insert<T>(_ option: T) where T: RawRepresentable, T.RawValue == UInt8 {
        self.rawValue = self.rawValue | option.rawValue
    }
    
    mutating func remove<T>(_ element: T) where T: RawRepresentable, T.RawValue == UInt8 {
        self.rawValue = self.rawValue & ~element.rawValue
    }
}

// MARK: - CustomStringConvertible

extension BinaryArray: CustomStringConvertible {
    
    public var description: String {
        return "[" + reduce("", { $0 + ($0.isEmpty ? "" : ", ") + $1.description }) + "]"
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension BinaryArray: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension BinaryArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Bool...) {
        self.init()
        assert(elements.count <= 8, "More than 8 elements")
        elements.prefix(8).enumerated().forEach {
            self[$0] = $1
        }
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension BinaryArray: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Int, Bool)...) {
        self.init()
        assert(elements.count <= 8, "More than 8 elements")
        elements.forEach {
            assert($0.0 <= 8, "More than 8 elements")
            self[$0.0] = $0.1
        }
    }
}
