//
//  Position5Test.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 28.08.2025.
//

import XCTest

@testable import MaxolChess

private let pos = Position(fen: "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")!

final class Position5Test: XCTestCase {

    func testGenerateAllMoves() throws {
        let moveGen = PossibleMoveGeneratorImpl()

        measure {
            let moves = moveGen.generateAllMoves(pos)
            XCTAssertEqual(moves.count, 40)
        }
    }

    func testGenerateLegalMoves() throws {
        let legalMoveGen = LegalMoveGeneratorImpl()

        measure {
            let moves = legalMoveGen.generateLegalMoves(pos, parentMoveId: nil)
            XCTAssertEqual(moves.count, 40)
        }
    }

    func testEvaluation() throws {
        let posEvaluator = PositionEvaluatorImpl()

        measure {
            let eval = posEvaluator.evaluate(pos)
            XCTAssertEqual(eval.state, .normal)
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
                let move = await engine.calculateOurBestMove()
                logConsoleMarked(move)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100)
        }
    }

    func testBestMoveDepth2() {
        let options = XCTMeasureOptions()
        options.iterationCount = 2
        measure(options: options) {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 2),
                    gameState: GameState(position: pos)
                )
                let move = await engine.calculateOurBestMove()
                logConsoleMarked(move)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100)
        }
    }
}
