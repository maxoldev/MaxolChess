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
