//
//  Coordinate.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 16.08.2025.
//

public typealias File = String
public typealias Rank = Int

public struct Coordinate: Equatable, Sendable {
    public var x: Int
    public var y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public init(_ index: Int) {
        self.init(index % Const.boardSize, index / Const.boardSize)
    }

    public var index: Int {
        x + y * Const.boardSize
    }

    /// "a1", "e4", etc.
    public init?(_ string: String) {
        let string = string.lowercased()
        
        guard string.count == 2,
            let firstScalar = string.unicodeScalars.first?.value,
            let secondScalar = string.unicodeScalars.last?.value
        else {
            return nil
        }

        let fileIndex = Int(firstScalar) - 97  // starting from 'a'
        let rankIndex = Int(secondScalar) - 49  // starting from '1'
        let coord = Coordinate(fileIndex, rankIndex)
        if coord.isValid {
            self = coord
        } else {
            return nil
        }
    }

    /// - Returns: nil if advanced coordinate is invalid for the current board
    public func advancedBy(_ xOffset: Int, _ yOffset: Int) -> Self? {
        let newCoord = Coordinate(x + xOffset, y + yOffset)
        return newCoord.isValid ? newCoord : nil
    }

    public var isValid: Bool {
        x >= 0 && x < Const.boardSize && y >= 0 && y < Const.boardSize
    }

    public func within1SquareOf(_ other: Coordinate) -> Bool {
        abs(x - other.x) <= 1 && abs(y - other.y) <= 1
    }
}

extension Coordinate: CustomStringConvertible {
    public var description: String {
        String(UnicodeScalar(97 + x)!) + String(y + 1)
    }
}

extension Coordinate: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)!
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)!
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)!
    }
}
