//
//  PerformanceTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 28.08.2025.
//

import MaxolChess
import XCTest

private let pos = Position(fen: "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")!

final class Position5Test: XCTestCase {
    override class func setUp() {
        Config.shared = Config.performanceTestConfig
    }

    func testGenerateAllMoves() throws {
        let moveGen = PossibleMoveGeneratorImpl()

        measure {
            _ = moveGen.generateAllMoves(pos)
        }
    }

    func testGenerateLegalMoves() throws {
        let legalMoveGen = LegalMoveGeneratorImpl()

        measure {
            _ = legalMoveGen.generateLegalMoves(pos, parentMoveId: nil)
        }
    }

    func testEvaluation() throws {
        let posEvaluator = PositionEvaluatorImpl()

        measure {
            _ = posEvaluator.evaluate(pos)
        }
    }

    func testBestMoveDepth4() {
        measure {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 4),
                    gameState: GameState(position: pos)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 20)
        }
    }
}
