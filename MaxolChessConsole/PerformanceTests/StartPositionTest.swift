//
//  StartPositionTest.swift
//  PerformanceTests
//
//  Created by Maksim Solovev on 31.08.2025.
//

import XCTest

import MaxolChess

final class StartPositionTest: XCTestCase {
    func testGenerateAllMoves() throws {
        let moveGen = PossibleMoveGeneratorImpl()

        measure {
            _ = moveGen.generateAllMoves(Position.start)
        }
    }

    func testGenerateLegalMoves() throws {
        let legalMoveGen = LegalMoveGeneratorImpl()

        measure {
            _ = legalMoveGen.generateLegalMoves(Position.start, parentMoveId: nil)
        }
    }

    func testEvaluation() throws {
        let posEvaluator = PositionEvaluatorImpl()

        measure {
            _ = posEvaluator.evaluate(Position.start)
        }
    }

    func testBestMoveDepth4() {
        measure {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 4),
                    gameState: GameState(position: Position.start)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 20)
        }
    }
}
