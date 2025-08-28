//
//  Coordinate.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 16.08.2025.
//

public struct Coordinate: Equatable, Sendable {
    public var x: Int
    public var y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public init(_ index: Int) {
        self.init(index % Const.baseBoardSize, index / Const.baseBoardSize)
    }

    public var index: Int {
        x + y * Const.baseBoardSize
    }

    public var file: File {
        get {
            return String(UnicodeScalar(97 + x)!)
        }
        set {
            x = Int(newValue.unicodeScalars.first!.value) - 97
        }
    }

    public var rank: Rank {
        get {
            return y
        }
        set {
            y = newValue
        }
    }

    public init(_ string: String) {
        precondition(
            string.count == 2,
            "Coordinates must be two characters long (e.g. 'e2')"
        )
        let string = string.lowercased()
        let fileIndex = Int(string.unicodeScalars.first!.value - 97)
        let rankIndex = Int(string.unicodeScalars.last!.value - 49)
        x = fileIndex
        y = rankIndex
    }

    /// - Returns: nil if advanced coordinate is invalid for the current board
    public func advancedBy(_ xOffset: Int, _ yOffset: Int) -> Self? {
        if Self.isValid(x + xOffset, y + yOffset) {
            return Coordinate(x + xOffset, y + yOffset)
        } else {
            return nil
        }
    }

    public static func isValid(_ x: Int, _ y: Int) -> Bool {
        x >= 0 && x < Const.baseBoardSize && y >= 0 && y < Const.baseBoardSize
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
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
}

public typealias File = String
public typealias Rank = Int
