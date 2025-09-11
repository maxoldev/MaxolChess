//
//  Config.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 22.08.2025.
//

public struct Config {
    public struct Log {
        public let useUnicodePieceNotation: Bool

        public let moveId: Bool

        public let positionOfSearchFrom: Bool
        public let analysisDepth: Bool
        public let bestMove: Bool

        public enum Evaluation: Int {
            case none
            case rootMoves
            case furtherPositions
            case furtherPositionsWithMoveList
        }
        public let evaluation: Evaluation
    }
    public let log: Log

    nonisolated(unsafe) public static var shared: Config = Config(
        log: Log(
            useUnicodePieceNotation: false,
            moveId: true,
            positionOfSearchFrom: true,
            analysisDepth: false,
            bestMove: true,
            evaluation: .none
        )
    )
    nonisolated(unsafe) public static let game: Config = Config(
        log: Log(
            useUnicodePieceNotation: true,
            moveId: true,
            positionOfSearchFrom: true,
            analysisDepth: false,
            bestMove: true,
            evaluation: .none
        )
    )
    nonisolated(unsafe) public static let performanceTestConfig: Config = Config(
        log: Log(
            useUnicodePieceNotation: false,
            moveId: false,
            positionOfSearchFrom: false,
            analysisDepth: false,
            bestMove: false,
            evaluation: .none
        )
    )
}
