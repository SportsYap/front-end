import Foundation

extension Data {
    static func dataWithValue(value: Int8) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }

    func int8Value() -> Int8 {
        return Int8(bitPattern: self[0])
    }
}

extension Data {
    var hex: String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}

// UInt16 to [UInt8]
extension BinaryInteger {
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    var array: [UInt8] { return Array(self) }
}
