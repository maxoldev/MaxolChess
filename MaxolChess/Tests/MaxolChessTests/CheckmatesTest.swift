//
//  CheckmatesTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import Testing

@testable import MaxolChess

struct CheckmatesTest {
    @Test func checkmates() async throws {
        let positionEval = StaticPositionEvaluatorImpl()
        let val = positionEval.evaluate(
            Position(
                Board(
                    prettyPrinted: """
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
                turn: .black
            )
        )
        #expect(val == .kingCheckmated(.white))
    }
}
