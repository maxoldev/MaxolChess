//
//  StaticValueEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public protocol StaticValueCalculator {
    /// - Returns: Positive for whites advantage, negative for blacks
    func calculateOnlyDefaultValues(_ position: Position) -> Double
    /// - Returns: Positive for whites advantage, negative for blacks
    func calculate(_ position: Position) -> Double
}

public class StaticValueCalculatorImpl: StaticValueCalculator {
    public init() {
    }

    public func calculateOnlyDefaultValues(_ position: Position) -> Double {
        var whiteValue = 0.0
        var blackValue = 0.0

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

    public func calculate(_ position: Position) -> Double {
        var whiteValue = 0.0
        var blackValue = 0.0

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
