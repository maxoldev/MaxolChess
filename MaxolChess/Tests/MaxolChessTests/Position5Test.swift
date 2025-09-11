//
//  Position5Test.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 11.09.2025.
//

import Testing

@testable import MaxolChess

private let pos = Position(fen: "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")!

struct Position5Test {
    @Test func depth1() async throws {
        let engine = EngineImpl(
            configuration: EngineConfiguration(
                maxDepth: 1,
                positionToAnalyzeFurtherCount: Int.max,
                analyzeFurtherAfterCheckmateOnRootMove: true,
                collectStatistics: true
            ),
            gameState: GameState(position: pos)
        )
        _ = try #require(await engine.calculateBestMove())
        #expect(await engine.analysisStatistics.evaluatedPositionCount == 44)
        #expect(await engine.analysisStatistics.maxReachedDepth == 1)
    }

    @Test func depth2() async throws {
        let engine = EngineImpl(
            configuration: EngineConfiguration(
                maxDepth: 2,
                positionToAnalyzeFurtherCount: Int.max,
                analyzeFurtherAfterCheckmateOnRootMove: true,
                collectStatistics: true
            ),
            gameState: GameState(position: pos)
        )
        _ = try #require(await engine.calculateBestMove())
        #expect(await engine.analysisStatistics.evaluatedPositionCount == 1530)
        #expect(await engine.analysisStatistics.maxReachedDepth == 2)
    }

    @Test func depth3() async throws {
        let engine = EngineImpl(
            configuration: EngineConfiguration(
                maxDepth: 3,
                positionToAnalyzeFurtherCount: Int.max,
                analyzeFurtherAfterCheckmateOnRootMove: true,
                collectStatistics: true
            ),
            gameState: GameState(position: pos)
        )
        _ = try #require(await engine.calculateBestMove())
        #expect(await engine.analysisStatistics.maxReachedDepth == 3)
    }
}
