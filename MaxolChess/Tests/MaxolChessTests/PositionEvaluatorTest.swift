//
//  PositionEvaluatorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 21.08.2025.
//

import Testing

@testable import MaxolChess

struct PositionEvaluatorTest {
    let posEval = PositionEvaluatorImpl()
    let atLeastAdvantageForCheck = Const.Evaluation.check - 100

    @Test func start() async throws {
        #expect(posEval.evaluate(Position.start).advantage == 0)
    }

    @Test func normal() async throws {
        var posE3 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: "P", from: "e2", to: "e3"))
        var posE4 = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: "P", from: "e2", to: "e4"))
        posE3.sideToMove = .white
        posE4.sideToMove = .white
        let coefDiff = Const.boardCoordinateCoefficients[Coordinate("e4").index] - Const.boardCoordinateCoefficients[Coordinate("e3").index]
        let evalE3 = posEval.evaluate(posE3)
        let evalE4 = posEval.evaluate(posE4)
        #expect((evalE4.advantage - evalE3.advantage).isApproximatelyEqual(to: coefDiff))
    }

    @Test func check() async throws {
        let pos = Position(
            Board(
                multiline: """
                      ┌───────────────┐
                    8  . . . . . ♟ ♚ ♟
                    7  . . . . . ♟ ♟ ♙ 
                    6  . . . . . . . .
                    5  . . . . . . . . 
                    4  . . . . . . . .
                    3  . . . . . . . .
                    2  . . . . . . . .
                    1  . . . . ♔ . . .
                      └───────────────┘
                       a b c d e f g h 
                    """
            )!,
            sideToMove: .black
        )
        #expect(posEval.evaluate(pos).advantage >= atLeastAdvantageForCheck)
    }

    @Test func checkmate1() async throws {
        let pos = Position(
            Board(
                multiline: """
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
        #expect(posEval.evaluate(pos).advantage == Const.Evaluation.checkmate)
    }

    @Test func checkmate2() async throws {
        let pos = Position(
            Board(
                multiline: """
                      ┌───────────────┐
                    8  ♜ . . ♛ ♚ ♝ ♞ ♜ 
                    7  . . ♟ ♟ ♟ ♙ ♟ ♟ 
                    6  ♟ . . . . . . . 
                    5  . ♟ . . . . ♘ . 
                    4  . . . . . . . . 
                    3  . . ♙ . . . . . 
                    2  ♙ ♙ . ♔ ♗ ♙ ♝ ♙ 
                    1  ♖ ♘ ♗ ♕ . . . . 
                      └───────────────┘
                       a b c d e f g h 
                    """
            )!,
            sideToMove: .black
        )
        #expect(posEval.evaluate(pos).advantage == Const.Evaluation.checkmate)
    }

    @Test func checkmate3() async throws {
        let pos = Position(
            Board(
                multiline: """
                      ┌───────────────┐
                    8  . . . . . ♟ ♚ ♟
                    7  . . . . . ♟ ♟ ♙ 
                    6  . . . . . . ♙ .
                    5  . . . . . . . . 
                    4  . . . . . . . .
                    3  . . . . . . . .
                    2  . . . . . . . .
                    1  . . . . ♔ . . .
                      └───────────────┘
                       a b c d e f g h 
                    """
            )!,
            sideToMove: .black
        )
        #expect(posEval.evaluate(pos).advantage == Const.Evaluation.checkmate)
    }

    @Test func checkmate4() async throws {
        let evaluation = posEval.evaluate(
            Position(
                Board(
                    multiline: """
                          ┌───────────────┐
                        8  ♜ . . . . . . .
                        7  . . . ♞ . ♚ ♟ .
                        6  . . ♟ ♟ . . . .
                        5  . ♟ . . ♟ . . ♙
                        4  . . . . ♕ . ♙ .
                        3  . . . . . ♙ . .
                        2  ♛ ♙ ♙ . . . . .
                        1  . ♔ ♖ . . . . ♖
                          └───────────────┘
                           a b c d e f g h
                        """
                )!,
                sideToMove: .white
            )
        )
        #expect(evaluation.advantage == -Const.Evaluation.checkmate)
    }
}
