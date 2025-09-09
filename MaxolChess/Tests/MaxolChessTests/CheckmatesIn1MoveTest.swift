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
            gameState: GameState(
                position: Position(
                    Board(
                        multiline: """
                              ┌───────────────┐
                            8  ♜ . . . . . . .
                            7  . . . ♞ . ♚ ♟ .
                            6  . . ♟ ♟ ♛ . . .
                            5  . ♟ . . ♟ . . ♙
                            4  . . . . ♕ . ♙ .
                            3  . . . . . ♙ . .
                            2  . ♙ ♙ . . . . .
                            1  . ♔ ♖ . . . . ♖
                              └───────────────┘
                               a b c d e f g h 
                            """
                    )!,
                    sideToMove: .black
                )
            )
        )
        #expect(try #require(await engine.calculateBestMove() as? RepositionMove).to == "a2")
    }

    @Test func checkmateIn1Move2() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(
                position: Position(
                    Board(
                        multiline: """
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
        let engine: Engine = EngineImpl(
            gameState: GameState(
                position: Position(
                    Board(
                        multiline: """
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

    @Test func checkmateIn1Move4() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(
                position: Position(
                    Board(
                        multiline: """
                              ┌───────────────┐
                            8  . . . . . ♟ ♚ ♟
                            7  . . . . . ♟ ♟ . 
                            6  . . . . . . ♙ ♙
                            5  . . . . . . . . 
                            4  . . . . . . . .
                            3  . . . . . . . .
                            2  . . . . . . . .
                            1  . . . . ♔ . . .
                              └───────────────┘
                               a b c d e f g h 
                            """
                    )!,
                    sideToMove: .white
                )
            )
        )
        #expect(try #require(await engine.calculateBestMove() as? RepositionMove).to == "h7")
    }
}
