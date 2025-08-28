//
//  ValueEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct ValueCalculation: Equatable {
    public let white: PieceValue
    public let black: PieceValue

    public subscript (_ color: PieceColor) -> PieceValue {
        get {
            color == .white ? white : black
        }
    }
}

public protocol ValueCalculator {
    /// - Returns: Doesn't take pieces' placement into account
    func calculateOnlyDefaultValues(_ position: Position) -> ValueCalculation
    /// - Returns: Takes pieces' placement into account
    func calculate(_ position: Position) -> ValueCalculation
}

public class ValueCalculatorImpl: ValueCalculator {
    public init() {
    }

    public func calculateOnlyDefaultValues(_ position: Position) -> ValueCalculation {
        var whiteValue: PieceValue = 0.0
        var blackValue: PieceValue = 0.0

        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = position.board[coordinate] {
                if piece.color == .white {
                    whiteValue += piece.type.defaultValue
                } else {
                    blackValue += piece.type.defaultValue
                }
            }
        }

        return ValueCalculation(white: whiteValue, black: blackValue)
    }

    public func calculate(_ position: Position) -> ValueCalculation {
        var whiteValue: PieceValue = 0.0
        var blackValue: PieceValue = 0.0

        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = position.board[coordinate] {
                if piece.color == .white {
                    whiteValue +=
                        piece.type.defaultValue
                        + (piece.type == .king ? Const.boardCoordinateCoefficientsForWhiteKing[i] : Const.boardCoordinateCoefficients[i])
                } else {
                    blackValue +=
                        piece.type.defaultValue
                        + (piece.type == .king ? Const.boardCoordinateCoefficientsForBlackKing[i] : Const.boardCoordinateCoefficients[i])
                }
            }
        }

        return ValueCalculation(white: whiteValue, black: blackValue)
    }
}
