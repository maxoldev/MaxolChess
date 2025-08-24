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
        let pos1 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e3"))
        let pos2 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e4"))

        let posEval = PositionEvaluatorImpl()
        let coefDiff = Const.boardCoordinateCoefficients[Coordinate("e4").index] - Const.boardCoordinateCoefficients[Coordinate("e3").index]
        let eval1 = posEval.evaluate(pos1)
        let eval2 = posEval.evaluate(pos2)
        switch (eval1, eval2) {
        case let (.normal(adv1), .normal(adv2)):
            #expect((adv2 - adv1).isApproximatelyEqual(to: coefDiff))
        default:
            Issue.record("Invalid evaluation")
        }
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
            turn: .white
        )

        let posEval = PositionEvaluatorImpl()
        #expect(posEval.evaluate(pos) == .kingCheckmated(.black))
    }
}
