//
//  StaticValueCalculationTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct StaticValueCalculationTest {
    @Test func defaultValue() async throws {
        let staticValueCalc = StaticValueCalculatorImpl()

        #expect(staticValueCalc.calculateOnlyDefaultValues(Position.start) == 0)

        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .pawn), "e4")), turn: .white)) == 1)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .knight), "e4")), turn: .white)) == 3)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .bishop), "e4")), turn: .white)) == 3)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .rook), "e4")), turn: .white)) == 5)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .queen), "e4")), turn: .white)) == 9)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.white, .king), "e4")), turn: .white)) == 1000)

        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .pawn), "e4")), turn: .white)) == -1)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .knight), "e4")), turn: .white)) == -3)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .bishop), "e4")), turn: .white)) == -3)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .rook), "e4")), turn: .white)) == -5)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .queen), "e4")), turn: .white)) == -9)
        #expect(staticValueCalc.calculateOnlyDefaultValues(Position(Board(pieces: (Piece(.black, .king), "e4")), turn: .white)) == -1000)
    }

    @Test func boardCoordinateCoefficients() {
        let coefs = Const.boardCoordinateCoefficients

        #expect(coefs.count == Const.baseBoardSquareCount)
        for i in 0..<Const.baseBoardSquareCount / 2 {
            #expect(coefs[i] == coefs[Const.baseBoardSquareCount - i - 1])
        }
    }

    @Test func scaledValue() async throws {
        let staticValueCalc = StaticValueCalculatorImpl()

        #expect(staticValueCalc.calculate(Position.start) == 0)

        #expect(
            staticValueCalc.calculate(Position(Board(pieces: (Piece(.white, .pawn), "e4")), turn: .white)) == 1
                + Const.boardCoordinateCoefficients[Coordinate("e4").index]
        )
    }
}
