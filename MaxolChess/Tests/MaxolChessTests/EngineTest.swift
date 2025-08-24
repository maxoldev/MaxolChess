//
//  EngineTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 20.08.2025.
//

import Testing

@testable import MaxolChess
import Foundation

struct EngineTest {
    @Test func test0() async throws {
        let pos = Position(fen: "4k3/4p3/8/8/8/8/4P3/4K3 w - - 0 1")!

        let engine: Engine = EngineImpl(
            gameState: GameState(ourSide: .white, position: pos)
        )
        let move = await engine.calculateOurBestMove()
        logConsoleMarked(move)
    }
    
    @Test func test() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(ourSide: .white, position: Position.start)
        )
        logConsoleMarked(engine.getCurrentState().position)
        var move = await engine.calculateOurBestMove()
        engine.setOurMove(move!)
        engine.setOpponentsMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e7", to: "e6"))
        move = await engine.calculateOurBestMove()
        engine.setOurMove(move!)
        engine.setOpponentsMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e6", to: "e5"))
        move = await engine.calculateOurBestMove()
        
    }
}
