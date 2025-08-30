//
//  BenchmarkTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 28.08.2025.
//

import XCTest

@testable import MaxolChess

private let pos = Position(fen: "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")!

final class BenchmarkTest: XCTestCase {

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

    func testBestMoveDepth1() {
        measure {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 1),
                    gameState: GameState(position: pos)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100)
        }
    }

    func testBestMoveDepth2() {
        measure {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 2),
                    gameState: GameState(position: pos)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100)
        }
    }

    func testBestMoveDepth3() {
        let options = XCTMeasureOptions()
        options.iterationCount = 4
        measure(options: options) {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 3),
                    gameState: GameState(position: pos)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100)
        }
    }

    func testBestMoveDepth4() {
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        measure(options: options) {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 4),
                    gameState: GameState(position: pos)
                )
                _ = await engine.calculateBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 300)
        }
    }
}
