//
//  CheckmatesIn1MoveTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct CheckmatesIn1MoveTest {
    @Test func checkmateIn1Move1() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(position: Position(fen: "1KR4R/PPP5/5P2/4Q1P1/1p2p2P/2ppq3/3n1kp1/r7 b KQ - 0 1")!)
        )
        #expect(try #require(await engine.calculateBestMove() as? CaptureMove).to == "a7")
    }

    @Test func checkmateIn1Move2() async throws {
        let engine: Engine = EngineImpl(
            gameState:
                GameState(
                    position: Position(
                        Board(
                            prettyPrinted: """
                                  ┌───────────────┐
                                8  ♜ . . ♛ ♚ ♝ ♞ ♜ 
                                7  . . ♟ ♟ ♟ . ♟ ♟ 
                                6  ♟ . . . . ♙ . . 
                                5  . ♟ . . . . ♘ . 
                                4  . . . . . . . . 
                                3  . . ♙ . . . . . 
                                2  ♙ ♙ . ♔ ♗ ♙ ♝ ♙ 
                                1  ♖ ♘ ♗ ♕ . . . . 
                                  └───────────────┘
                                   a b c d e f g h 
                                """
                        )!,
                        sideToMove: .white
                    )
                )
        )
        #expect(try #require(await engine.calculateBestMove() as? RepositionMove).to == "f7")
    }

    @Test func checkmateIn1Move3() async throws {
        let engine: Engine = EngineImpl()
        engine.setCurrentState(
            GameState(
                position: Position(
                    Board(
                        prettyPrinted: """
                              ┌───────────────┐
                            8  . . . . . . ♖ . 
                            7  . . ♗ . . . . . 
                            6  ♟ ♙ . . . . . . 
                            5  ♚ . . . . . . . 
                            4  ♟ ♟ . . . . . . 
                            3  . . . . . . . . 
                            2  . . . . . . . . 
                            1  ♜ . . . . . ♖ ♔ 
                              └───────────────┘
                               a b c d e f g h 
                            """
                    )!,
                    sideToMove: .white
                )
            )
        )
        let move = try #require(await engine.calculateBestMove() as? RepositionMove)
        #expect(move.isEqual(to: RepositionMove(parentMoveId: nil, piece: Piece(.white, .rook), from: "g8", to: "g5")))
    }
}
