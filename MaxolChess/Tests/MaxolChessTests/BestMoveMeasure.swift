//
//  BestMoveMeasure.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 27.08.2025.
//

import XCTest

@testable import MaxolChess

final class BestMoveMeasure: XCTestCase {
    func test() {
        measure {
            let expectation = XCTestExpectation()
            Task {
                let engine: Engine = EngineImpl(
                    configuration: EngineConfiguration(maxDepth: 3),
                    gameState: GameState(position: Position.start)
                )
                _ = await engine.calculateOurBestMove()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 100.0)
        }
    }
}
