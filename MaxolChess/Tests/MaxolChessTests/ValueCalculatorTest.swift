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

        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .pawn), "e4")), sideToMove: .white)).white == 1)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .knight), "e4")), sideToMove: .white)).white == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .bishop), "e4")), sideToMove: .white)).white == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .rook), "e4")), sideToMove: .white)).white == 5)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .queen), "e4")), sideToMove: .white)).white == 9)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .king), "e4")), sideToMove: .white)).white == 1000)

        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .pawn), "e4")), sideToMove: .white)).black == 1)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .knight), "e4")), sideToMove: .white)).black == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .bishop), "e4")), sideToMove: .white)).black == 3)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .rook), "e4")), sideToMove: .white)).black == 5)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .queen), "e4")), sideToMove: .white)).black == 9)
        #expect(valueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .king), "e4")), sideToMove: .white)).black == 1000)
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
