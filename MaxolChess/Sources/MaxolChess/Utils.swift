//
//  Utils.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

import Foundation

extension UUID {
    var shortString: String {
        return shortString(length: 8)
    }

    func shortString(length: Int = 8) -> String {
        let uuidStr = self.uuidString.replacingOccurrences(of: "-", with: "")
        let endIndex = uuidStr.index(uuidStr.startIndex, offsetBy: min(length, uuidStr.count))
        return String(uuidStr[..<endIndex])
    }
}

func delayed<T>(_ val: T, atLeast: TimeInterval) async -> T {
    async let timer: ()? = try? await Task.sleep(for: .seconds(atLeast))
    return await (val, timer).0
}

public class Benchmark {
    public struct BenchmarkTime: CustomStringConvertible {
        public let seconds: Double

        public var description: String {
            "⏱️\(seconds) sec."
        }
    }

    private var start = DispatchTime.now()

    public func checkpoint() -> BenchmarkTime {
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        start = end
        let timeInterval = Double(nanoTime) / Double(NSEC_PER_SEC)
        return BenchmarkTime(seconds: timeInterval)
    }

    public func reset() {
        start = DispatchTime.now()
    }
}

extension Float {
    public func isApproximatelyEqual(to other: Float, tolerance: Float = 1e-9) -> Bool {
        return abs(self - other) <= tolerance
    }
}

extension Double {
    public func isApproximatelyEqual(to other: Double, tolerance: Double = 1e-9) -> Bool {
        return abs(self - other) <= tolerance
    }
}
