//
//  EngineTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 20.08.2025.
//

import Testing

@testable import MaxolChess

struct EngineTest {
    @Test func test() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(ourSide: .white, position: Position.start)
        )
        var move = await engine.calculateOurBestMove()
        print(move)
        engine.setOurMove(move!)
        engine.setOpponentsMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e7", to: "e6"))
        move = await engine.calculateOurBestMove()
        print(move)
        engine.setOurMove(move!)
        engine.setOpponentsMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e6", to: "e5"))
        move = await engine.calculateOurBestMove()
        print(move)
    }
}
