//
//  Engine.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

import Foundation

public struct GameState {
    public var position: Position
    public var playedMoves: [Move] = []

    public init(position: Position, previousMoves: [Move] = []) {
        self.position = position
        self.playedMoves = previousMoves
    }
}

public enum AnalisysLimit {
    /// Seconds
    //case time(Double)
    /// In 2 halfmoves
    case depth(Int)
}

public struct EngineConfiguration: Sendable {
    //    public var analisysLimit: AnalisysLimit = .depth(2)
    /// In halfmoves
    public let maxDepth: Int
    public let analyzeFurtherAfterCheckmateOnFirstDepth: Bool

    public init(maxDepth: Int = 2, analyzeFurtherAfterCheckmateOnFirstDepth: Bool = false) {
        self.maxDepth = maxDepth
        self.analyzeFurtherAfterCheckmateOnFirstDepth = analyzeFurtherAfterCheckmateOnFirstDepth
    }
}

public protocol Engine {
    func getCurrentState() -> GameState
    func setCurrentState(_ state: GameState)

    func calculateBestMove() async -> Move?
    func setMove(_ move: Move)

    func updateConfiguration(_ configuration: EngineConfiguration)
}

public final class EngineImpl: Engine {
    fileprivate struct EvaluatedRootMove {
        let move: Move
        let aggregatedAdvantage: Double
    }

    private let configuration: EngineConfiguration
    private let valueCalculator: ValueCalculator
    private let positionEvaluator: PositionEvaluator
    private let legalMoveGenerator: LegalMoveGenerator

    private var currentState: GameState
    private let evaluationCache: EvaluationCache

    public init(
        configuration: EngineConfiguration = EngineConfiguration(),
        valueCalculator: ValueCalculator = ValueCalculatorImpl(),
        positionEvaluator: PositionEvaluator = PositionEvaluatorImpl(),
        legalMoveGenerator: LegalMoveGenerator = LegalMoveGeneratorImpl(),
        evaluationCache: EvaluationCache = EvaluationCacheImpl(),
        gameState: GameState = GameState(position: Position.start)
    ) {
        self.configuration = configuration
        self.valueCalculator = valueCalculator
        self.positionEvaluator = positionEvaluator
        self.legalMoveGenerator = legalMoveGenerator
        self.evaluationCache = evaluationCache
        self.currentState = gameState
    }

    // MARK: - Engine
    public func getCurrentState() -> GameState {
        currentState
    }

    public func setCurrentState(_ state: GameState) {
        currentState = state
    }

    // MARK: - Analysis
    public func calculateBestMove() async -> Move? {
        if Config.shared.log.positionOfSearchFrom {
            logDebug("Searching for the best move in position:", currentState.position, category: .engine)
        }
        let bench = Benchmark()

        let moves = legalMoveGenerator.generateLegalMoves(currentState.position, parentMoveId: nil)

        var evaluatedMoves = [EvaluatedRootMove]()

        for move in moves {
            let posAfterMove = currentState.position.applied(move: move)

            let evaluation = positionEvaluator.evaluate(posAfterMove)

            if Config.shared.log.evaluation.rawValue >= Config.Log.Evaluation.rootMoves.rawValue {
                logDebug("🥾Root move evaluation:", move, posAfterMove, evaluation, separator: "\n", category: .engine)
            }

            let furtherMovesAdvantageSum: Double
            if configuration.maxDepth > 1 {
                let logMovesDuringEvaluation = Config.shared.log.evaluation == .furtherPositionsWithMoveList

                furtherMovesAdvantageSum = await Self.analyze(
                    position: posAfterMove,
                    movesToThisPosition: logMovesDuringEvaluation ? [move] : nil,
                    ourSide: currentState.position.sideToMove,
                    parentMoveId: move.id,
                    currentDepth: 0,
                    configuration: configuration,
                    positionEvaluator: positionEvaluator,
                    legalMoveGenerator: legalMoveGenerator,
                    evaluationCache: evaluationCache
                )
            } else {
                furtherMovesAdvantageSum = 0
            }

            let aggregatedAdvantage = evaluation.advantage + furtherMovesAdvantageSum

            if Config.shared.log.evaluation.rawValue >= Config.Log.Evaluation.rootMoves.rawValue {
                logDebug("🥾📊Root move total:", move, posAfterMove, aggregatedAdvantage, separator: "\n", category: .engine)
            }
            evaluatedMoves.append(EvaluatedRootMove(move: move, aggregatedAdvantage: aggregatedAdvantage))
        }

        let conditionForWhite: (EvaluatedRootMove, EvaluatedRootMove) -> Bool = { lhs, rhs in
            lhs.aggregatedAdvantage < rhs.aggregatedAdvantage
        }
        let conditionForBlack: (EvaluatedRootMove, EvaluatedRootMove) -> Bool = { lhs, rhs in
            lhs.aggregatedAdvantage > rhs.aggregatedAdvantage
        }
        let bestMove = evaluatedMoves.max(by: currentState.position.sideToMove == .white ? conditionForWhite : conditionForBlack)

        if Config.shared.log.bestMove {
            let analyzedPositionCount = 0
            let cachedPositionCount = await evaluationCache.itemCount()
            logDebug(
                "BEST MOVE: \(bestMove as Any? ?? "NO VALID MOVES FOUND :(")",
                bench.checkpoint(),
                "\(analyzedPositionCount) analyzed positions, \(cachedPositionCount) cached positions",
                category: .engine
            )
        }

        return bestMove?.move
    }

    public func setMove(_ move: Move) {
        apply(move: move)
    }

    public func updateConfiguration(_ configuration: EngineConfiguration) {
        fatalError()
    }

    // MARK: - Private
    private func apply(move: Move) {
        currentState.position = currentState.position.applied(move: move)
        currentState.playedMoves.append(move)
    }

    private static func analyze(
        position: Position,
        movesToThisPosition: [Move]? = nil,
        ourSide: PieceColor,
        parentMoveId: MoveId?,
        currentDepth: Int,
        configuration: EngineConfiguration,
        positionEvaluator: PositionEvaluator,
        legalMoveGenerator: LegalMoveGenerator,
        evaluationCache: EvaluationCache
    ) async -> Double {
        if Config.shared.log.analysisDepth {
            logDebug("Analysis... Depth = \(currentDepth + 1) halfmoves", category: .engine)
        }

        let sideToMove = position.sideToMove

        typealias EvaluatedPosition = (position: Position, afterMove: Move, evaluation: PositionEvaluation)

        var evaluatedPositions = [EvaluatedPosition]()

        let moves = legalMoveGenerator.generateLegalMoves(position, parentMoveId: parentMoveId)

        evaluatedPositions.reserveCapacity(moves.count)

        evaluatedPositions = moves.map { move in
            let posAfterMove = position.applied(move: move)

            let evaluation = positionEvaluator.evaluate(posAfterMove)
//            let evaluation: PositionEvaluation
//            let posFEN = posAfterMove.fenBoardString
//            if let cachedEvaluation = await evaluationCache.get(posFEN) {
//                evaluation = cachedEvaluation
//            } else {
//                evaluation = positionEvaluator.evaluate(posAfterMove)
//                await evaluationCache.set(evaluation, for: posFEN)
//            }

            if Config.shared.log.evaluation.rawValue >= Config.Log.Evaluation.furtherPositions.rawValue {
                let title = "🥾Further move evaluation (depth=\(currentDepth)):"

                if Config.shared.log.evaluation == .furtherPositionsWithMoveList {
                    logDebug(
                        title,
                        move,
                        posAfterMove,
                        evaluation,
                        movesToThisPosition.map { $0 + [move] },
                        separator: "\n",
                        category: .engine
                    )
                } else {
                    logDebug(
                        title,
                        move,
                        posAfterMove,
                        evaluation,
                        separator: "\n",
                        category: .engine
                    )
                }
            }

            return (posAfterMove, move, evaluation)
        }

        // Every depth adds less value to the summarized advantage of the root move
        var advantageSum = evaluatedPositions.reduce(0.0) { $0 + $1.evaluation.advantage } * pow(10.0, -Double(currentDepth) - 1)

        if Config.shared.log.evaluation == .furtherPositions {
            logDebug("Position sum:", position, advantageSum, separator: "\n", category: .engine)
        }

        guard currentDepth + 1 < configuration.maxDepth else {
            return advantageSum
        }

        func sortForWhite(lhs: EvaluatedPosition, rhs: EvaluatedPosition) -> Bool {
            lhs.evaluation.advantage > rhs.evaluation.advantage
        }
        func sortForBlack(lhs: EvaluatedPosition, rhs: EvaluatedPosition) -> Bool {
            lhs.evaluation.advantage < rhs.evaluation.advantage
        }
        let positionsToAnalyzeFurther = evaluatedPositions.sorted(by: sideToMove == .white ? sortForWhite : sortForBlack)
            .prefix(Config.shared.analisys.positionToAnalyzeFurtherCount)

        if Config.shared.analisys.multithreaded {
            await withTaskGroup(of: Double.self) { group in
                for positionToAnalyzeFurther in positionsToAnalyzeFurther {
                    group.addTask {
                    await analyze(
                        position: positionToAnalyzeFurther.position,
                            movesToThisPosition: movesToThisPosition.map { $0 + [positionToAnalyzeFurther.afterMove] },
                            ourSide: ourSide,
                            parentMoveId: positionToAnalyzeFurther.afterMove.id,
                            currentDepth: currentDepth + 1,
                            configuration: configuration,
                            positionEvaluator: positionEvaluator,
                            legalMoveGenerator: legalMoveGenerator,
                            evaluationCache: evaluationCache
                        )
                    }
                }

                for await sub in group {
                    advantageSum += sub
                }
            }
        } else {
            for positionToAnalyzeFurther in positionsToAnalyzeFurther {
                advantageSum += await analyze(
                    position: positionToAnalyzeFurther.position,
                    movesToThisPosition: movesToThisPosition.map { $0 + [positionToAnalyzeFurther.afterMove] },
                    ourSide: ourSide,
                    parentMoveId: positionToAnalyzeFurther.afterMove.id,
                    currentDepth: currentDepth + 1,
                    configuration: configuration,
                    positionEvaluator: positionEvaluator,
                    legalMoveGenerator: legalMoveGenerator,
                    evaluationCache: evaluationCache
                )
            }
        }

        return advantageSum
    }
}

extension EngineImpl.EvaluatedRootMove: CustomStringConvertible {
    var description: String {
        "\(move) Aggregated advantage=\(aggregatedAdvantage)"
    }
}
