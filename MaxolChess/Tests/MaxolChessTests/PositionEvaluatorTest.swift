//
//  PositionEvaluatorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 21.08.2025.
//

import Testing

@testable import MaxolChess

struct PositionEvaluatorTest {
    @Test func normal() async throws {
        let posE3 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e3"))
        let posE4 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e4"))

        let posEval = PositionEvaluatorImpl()
        let coefDiff = Const.boardCoordinateCoefficients[Coordinate("e4").index] - Const.boardCoordinateCoefficients[Coordinate("e3").index]
        let evalE3 = posEval.evaluate(posE3)
        let evalE4 = posEval.evaluate(posE4)
        #expect((evalE4.values[.white] - evalE3.values[.white]).isApproximatelyEqual(to: coefDiff))
    }

    @Test func checkmates() async throws {
        let pos = Position(
            Board(
                prettyPrinted: """
                      ┌───────────────┐
                    8  . . . . . . . . 
                    7  . . ♗ . . . . . 
                    6  ♟ ♙ . . . . . . 
                    5  ♚ . . . . . ♖ . 
                    4  ♟ ♟ . . . . . . 
                    3  . . . . . . . . 
                    2  . . . . . . . . 
                    1  ♜ . . . . . ♖ ♔ 
                      └───────────────┘
                       a b c d e f g h 
                    """
            )!,
            sideToMove: .black
        )

        let posEval = PositionEvaluatorImpl()
        #expect(posEval.evaluate(pos).state == .kingCheckmated)
    }
}
