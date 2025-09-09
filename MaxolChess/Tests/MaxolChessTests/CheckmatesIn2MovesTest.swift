//
//  CheckmatesIn2MovesTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 08.09.2025.
//

import Testing

@testable import MaxolChess

struct CheckmatesIn2MovesTest {
    @Test func checkmateIn2Moves1() async throws {
        let engine: Engine = EngineImpl(configuration: EngineConfiguration(maxDepth: 2),
            gameState: GameState(
                position: Position(
                    Board(
                        multiline: """
                              ┌───────────────┐
                            8  . . . . . . . .
                            7  . . . . . . . k
                            6  R R . . . . . .
                            5  . . . . . . . .
                            4  . . . . . . . .
                            3  . . . . . . . .
                            2  . . . . . . . .
                            1  . . . . K . . .
                              └───────────────┘
                               a b c d e f g h 
                            """
                    )!,
                    sideToMove: .white
                )
            )
        )
        let whiteMove1 = try #require(await engine.calculateBestMove() as? RepositionMove)
        #expect(whiteMove1.to == "a7" || whiteMove1.to == "b7")
        logConsoleMarked(whiteMove1)

        engine.setMove(whiteMove1)

        let blackMove1 = try #require(await engine.calculateBestMove() as? RepositionMove)
        #expect(blackMove1.to == "g8" || blackMove1.to == "h8")

        engine.setMove(blackMove1)

        let whiteMove2 = try #require(await engine.calculateBestMove() as? RepositionMove)
        logConsoleMarked(whiteMove2)
        #expect(whiteMove2.to == "a8" || whiteMove2.to == "b8")
    }
}
