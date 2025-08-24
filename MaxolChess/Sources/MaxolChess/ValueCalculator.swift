//
//  ValueEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public protocol ValueCalculator {
    /// - Returns: Positive for whites advantage, negative for blacks
    func calculateOnlyDefaultValues(_ position: Position) -> PieceValue
    /// - Returns: Positive for whites advantage, negative for blacks
    func calculate(_ position: Position) -> PieceValue
}

public class ValueCalculatorImpl: ValueCalculator {
    public init() {
    }

    public func calculateOnlyDefaultValues(_ position: Position) -> PieceValue {
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

        return whiteValue - blackValue
    }

    public func calculate(_ position: Position) -> PieceValue {
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

        return whiteValue - blackValue
    }
}
