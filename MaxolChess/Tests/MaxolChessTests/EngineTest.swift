//
//  EngineTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 20.08.2025.
//

import Foundation
import Testing
import XCTest

@testable import MaxolChess

struct EngineTest {
    @Test func test0() async throws {
        let pos = Position(fen: "4k3/4p3/8/8/8/8/4P3/4K3 w - - 0 1")!

        let engine: Engine = EngineImpl(
            gameState: GameState(position: pos)
        )
        let move = await engine.calculateBestMove()
        logConsoleMarked(move)
    }

    @Test func test() async throws {
        let engine: Engine = EngineImpl(
            gameState: GameState(position: Position.start)
        )
        var move = await engine.calculateBestMove()
        engine.setMove(move!)
        engine.setMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e7", to: "e6"))
        move = await engine.calculateBestMove()
        engine.setMove(move!)
        engine.setMove(RepositionMove(parentMoveId: nil, piece: Piece(.black, .pawn), from: "e6", to: "e5"))
        move = await engine.calculateBestMove()
    }
}
