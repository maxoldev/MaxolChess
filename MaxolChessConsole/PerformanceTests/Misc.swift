//
//  Misc.swift
//  MaxolChessConsole
//
//  Created by Maksim Solovev on 11.09.2025.
//

import MaxolChess

func engineForPerformaceTests(with position: Position) -> Engine {
    EngineImpl(
        configuration: EngineConfiguration(maxDepth: 4, positionToAnalyzeFurtherCount: 5),
        gameState: GameState(position: position)
    )
}
