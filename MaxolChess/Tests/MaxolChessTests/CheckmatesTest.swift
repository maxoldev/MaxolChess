//
//  CheckmatesTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import MaxolChess
import Testing

struct CheckmatesTest {
    @Test func checkmates() async throws {
        let positionEval = PositionEvaluatorImpl()
        let evaluation = positionEval.evaluate(
            Position(
                Board(
                    multiline: """
                          ┌───────────────┐
                        8  . ♔ ♖ . . . . ♖
                        7  ♛ ♙ ♙ . . . . .
                        6  . . . . . ♙ . .
                        5  . . . . ♕ . ♙ .
                        4  . ♟ . . ♟ . . ♙
                        3  . . ♟ ♟ . . . .
                        2  . . . ♞ . ♚ ♟ .
                        1  ♜ . . . . . . .
                          └───────────────┘
                           a b c d e f g h
                        """
                )!,
                sideToMove: .white
            )
        )
        #expect(evaluation.state == .kingCheckmated)
    }
}
