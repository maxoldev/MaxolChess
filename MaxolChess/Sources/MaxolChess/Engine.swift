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

public struct EngineConfiguration: Sendable {
    /// In halfmoves. Values less than 1 are considered as 1
    public let maxDepth: Int
    /// On each depth only this N moves with the best advantage are considered for further analysis
    public let positionToAnalyzeFurtherCount: Int
    public let analyzeFurtherAfterCheckmateOnRootMove: Bool

    public let collectStatistics: Bool

    public let multithreaded: Bool

    public init(
        maxDepth: Int = 2,
        positionToAnalyzeFurtherCount: Int = 5,
        analyzeFurtherAfterCheckmateOnRootMove: Bool = false,
        collectStatistics: Bool = false,
        multithreaded: Bool = true,
    ) {
        self.maxDepth = maxDepth
        self.positionToAnalyzeFurtherCount = positionToAnalyzeFurtherCount
        self.analyzeFurtherAfterCheckmateOnRootMove = analyzeFurtherAfterCheckmateOnRootMove
        self.collectStatistics = collectStatistics
        self.multithreaded = multithreaded
    }
}

extension EngineConfiguration: CustomStringConvertible {
    public var description: String {
        "Max depth: \(maxDepth), Best positions to analyze further: \(positionToAnalyzeFurtherCount), AnalyzeFurtherAfterCheckmateOnRootMove: \(analyzeFurtherAfterCheckmateOnRootMove), Collect stats: \(collectStatistics), Multithreaded: \(multithreaded)"
    }
}

actor AnalysisStatistics: Sendable {
    var evaluatedPositionCount = 0
    var maxReachedDepth = 1

    fileprivate func incrementEvaluatedPositionCount(by count: Int) {
        evaluatedPositionCount += count
    }

    fileprivate func depthReached(_ value: Int) {
        maxReachedDepth = max(maxReachedDepth, value)
    }

    fileprivate func reset() {
        evaluatedPositionCount = 0
        maxReachedDepth = 1
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
        let positionAfterMove: Position
        var aggregatedAdvantage: Double
    }

    private let configuration: EngineConfiguration
    private let valueCalculator: ValueCalculator
    private let positionEvaluator: PositionEvaluator
    private let legalMoveGenerator: LegalMoveGenerator

    private var currentState: GameState
    private let evaluationCache: EvaluationCache

    let analysisStatistics = AnalysisStatistics()

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

    public func calculateBestMove() async -> Move? {
        if Config.shared.log.positionOfSearchFrom {
            logDebug("Searching for the best move in position:", currentState.position, configuration, separator: "\n", category: .engine)
        }
        let bench = Benchmark()
        await analysisStatistics.reset()

        let moves = legalMoveGenerator.generateLegalMoves(currentState.position, parentMoveId: nil)

        var evaluatedRootMoves = [EvaluatedRootMove]()
        var wasCheckmateFound = false

        let logMovesDuringEvaluation = Config.shared.log.evaluation == .furtherPositionsWithMoveList

        for move in moves {
            let posAfterMove = currentState.position.applied(move: move)

            let evaluation = positionEvaluator.evaluate(posAfterMove)

            if Config.shared.log.evaluation.rawValue >= Config.Log.Evaluation.rootMoves.rawValue {
                logDebug("🥾Root move evaluation:", move, posAfterMove, evaluation, separator: "\n", category: .engine)
            }

            if evaluation.state == .kingCheckmated {
                wasCheckmateFound = true
            }

            evaluatedRootMoves.append(
                EvaluatedRootMove(move: move, positionAfterMove: posAfterMove, aggregatedAdvantage: evaluation.advantage)
            )
        }

        if configuration.collectStatistics {
            await analysisStatistics.incrementEvaluatedPositionCount(by: moves.count)
        }

        if configuration.maxDepth > 1 {
            if !wasCheckmateFound || configuration.analyzeFurtherAfterCheckmateOnRootMove {
                for (idx, var rootMove) in evaluatedRootMoves.enumerated() {
                    let furtherMovesAdvantageSum = await Self.analyze(
                        position: rootMove.positionAfterMove,
                        movesToThisPosition: logMovesDuringEvaluation ? [rootMove.move] : nil,
                        parentMoveId: rootMove.move.id,
                        currentDepth: 2,
                        configuration: configuration,
                        positionEvaluator: positionEvaluator,
                        legalMoveGenerator: legalMoveGenerator,
                        evaluationCache: evaluationCache,
                        analysisStatistics: analysisStatistics
                    )
                    rootMove.aggregatedAdvantage += furtherMovesAdvantageSum
                    evaluatedRootMoves[idx] = rootMove
                }
            }
        }

        let conditionForWhite: (EvaluatedRootMove, EvaluatedRootMove) -> Bool = { lhs, rhs in
            lhs.aggregatedAdvantage < rhs.aggregatedAdvantage
        }
        let conditionForBlack: (EvaluatedRootMove, EvaluatedRootMove) -> Bool = { lhs, rhs in
            lhs.aggregatedAdvantage > rhs.aggregatedAdvantage
        }
        let bestMove = evaluatedRootMoves.max(by: currentState.position.sideToMove == .white ? conditionForWhite : conditionForBlack)

        if Config.shared.log.bestMove {
            let evaluatedPositionCount = await analysisStatistics.evaluatedPositionCount
            let maxReachedDepth = await analysisStatistics.maxReachedDepth
            let cachedPositionCount = await evaluationCache.itemCount()
            let stats =
                configuration.collectStatistics
                ? "\(evaluatedPositionCount) evaluated positions, \(cachedPositionCount) cached positions, Max reached depth: \(maxReachedDepth)"
                : "No statistics collected"
            logDebug(
                "BEST MOVE: \(bestMove as Any? ?? "NO VALID MOVES FOUND :(")",
                bench.checkpoint(),
                stats,
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
        parentMoveId: MoveId?,
        currentDepth: Int,
        configuration: EngineConfiguration,
        positionEvaluator: PositionEvaluator,
        legalMoveGenerator: LegalMoveGenerator,
        evaluationCache: EvaluationCache,
        analysisStatistics: AnalysisStatistics
    ) async -> Double {
        precondition(currentDepth > 1, "Depth starts from 1 and first depth moves calculations are performed in `bestMove` method")

        if Config.shared.log.analysisDepth {
            logDebug("Analysis... Depth = \(currentDepth) halfmoves", category: .engine)
        }
        if configuration.collectStatistics {
            await analysisStatistics.depthReached(currentDepth)
        }

        let sideToMove = position.sideToMove

        typealias EvaluatedPosition = (position: Position, afterMove: Move, evaluation: PositionEvaluation)

        var evaluatedPositions = [EvaluatedPosition]()

        let moves = legalMoveGenerator.generateLegalMoves(position, parentMoveId: parentMoveId)

        evaluatedPositions.reserveCapacity(moves.count)

        for move in moves {
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
                let title = "🥾Further move evaluation (depth: \(currentDepth)):"

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

            evaluatedPositions.append((posAfterMove, move, evaluation))
        }

        if configuration.collectStatistics {
            await analysisStatistics.incrementEvaluatedPositionCount(by: moves.count)
        }

        // Every depth adds less value to the summarized advantage of the root move
        var advantageSum = evaluatedPositions.reduce(0.0) { $0 + $1.evaluation.advantage } * pow(10.0, -Double(currentDepth) - 1)

        if Config.shared.log.evaluation == .furtherPositions {
            logDebug("Position sum:", position, advantageSum, separator: "\n", category: .engine)
        }

        guard currentDepth + 1 <= configuration.maxDepth else {
            return advantageSum
        }

        func sortForWhite(lhs: EvaluatedPosition, rhs: EvaluatedPosition) -> Bool {
            lhs.evaluation.advantage > rhs.evaluation.advantage
        }
        func sortForBlack(lhs: EvaluatedPosition, rhs: EvaluatedPosition) -> Bool {
            lhs.evaluation.advantage < rhs.evaluation.advantage
        }
        let positionsToAnalyzeFurther = evaluatedPositions.sorted(by: sideToMove == .white ? sortForWhite : sortForBlack)
            .prefix(configuration.positionToAnalyzeFurtherCount)

        if configuration.multithreaded {
            await withTaskGroup(of: Double.self) { group in
                for positionToAnalyzeFurther in positionsToAnalyzeFurther {
                    group.addTask {
                        await analyze(
                            position: positionToAnalyzeFurther.position,
                            movesToThisPosition: movesToThisPosition.map { $0 + [positionToAnalyzeFurther.afterMove] },
                            parentMoveId: positionToAnalyzeFurther.afterMove.id,
                            currentDepth: currentDepth + 1,
                            configuration: configuration,
                            positionEvaluator: positionEvaluator,
                            legalMoveGenerator: legalMoveGenerator,
                            evaluationCache: evaluationCache,
                            analysisStatistics: analysisStatistics
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
                    parentMoveId: positionToAnalyzeFurther.afterMove.id,
                    currentDepth: currentDepth + 1,
                    configuration: configuration,
                    positionEvaluator: positionEvaluator,
                    legalMoveGenerator: legalMoveGenerator,
                    evaluationCache: evaluationCache,
                    analysisStatistics: analysisStatistics
                )
            }
        }

        return advantageSum
    }
}

extension EngineImpl.EvaluatedRootMove: CustomStringConvertible {
    var description: String {
        "\(move), Aggregated advantage: \(aggregatedAdvantage)"
    }
}
