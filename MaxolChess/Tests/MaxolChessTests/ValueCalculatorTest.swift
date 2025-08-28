//
//  ValueCalculatorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct ValueCalculatorTest {
    @Test func defaultValue() async throws {
        let valueCalc = ValueCalculatorImpl()

        #expect(valueCalc.calculateOnlyDefaultValues(Position.start).white == valueCalc.calculateOnlyDefaultValues(Position.start).black)

        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("P", "e4")), sideToMove: .white)).white == 1)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("N", "e4")), sideToMove: .white)).white == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("B", "e4")), sideToMove: .white)).white == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("R", "e4")), sideToMove: .white)).white == 5)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("Q", "e4")), sideToMove: .white)).white == 9)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("K", "e4")), sideToMove: .white)).white == 1000)

        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("p", "e4")), sideToMove: .white)).black == 1)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("n", "e4")), sideToMove: .white)).black == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("b", "e4")), sideToMove: .white)).black == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("r", "e4")), sideToMove: .white)).black == 5)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("q", "e4")), sideToMove: .white)).black == 9)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: ("k", "e4")), sideToMove: .white)).black == 1000)
    }

    @Test func boardCoordinateCoefficients() {
        let coefs = Const.boardCoordinateCoefficients

        #expect(coefs.count == Const.baseBoardSquareCount)
        for i in 0..<Const.baseBoardSquareCount / 2 {
            #expect(coefs[i] == coefs[Const.baseBoardSquareCount - i - 1])
        }
    }

    @Test func scaledValue() async throws {
        let valueCalc = ValueCalculatorImpl()

        #expect(valueCalc.calculate(Position.start).white == valueCalc.calculate(Position.start).black)

        #expect(
            valueCalc.calculate(Position(Board(pieces: (Piece(.white, .pawn), "e4")), sideToMove: .white)).white == 1
                + Const.boardCoordinateCoefficients[Coordinate("e4").index]
        )
    }
}
