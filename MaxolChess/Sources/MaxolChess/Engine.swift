//
//  Engine.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

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
    private let configuration: EngineConfiguration
    private let valueCalculator: ValueCalculator
    private let positionEvaluator: PositionEvaluator
    private let legalMoveGenerator: LegalMoveGenerator

    private var currentState: GameState
    private let decider: Decider
    private let evaluationCache: EvaluationCache

    public init(
        configuration: EngineConfiguration = EngineConfiguration(),
        valueCalculator: ValueCalculator = ValueCalculatorImpl(),
        positionEvaluator: PositionEvaluator = PositionEvaluatorImpl(),
        legalMoveGenerator: LegalMoveGenerator = LegalMoveGeneratorImpl(),
        decider: Decider = DeciderImpl(),
        evaluationCache: EvaluationCache = EvaluationCacheImpl(),
        gameState: GameState = GameState(position: Position.start)
    ) {
        self.configuration = configuration
        self.valueCalculator = valueCalculator
        self.positionEvaluator = positionEvaluator
        self.legalMoveGenerator = legalMoveGenerator
        self.decider = decider
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
        logDebug("Analyzed position:", currentState.position, category: .engine)
        let bench = Benchmark()

        await decider.clear()

        await Self.analyze(
            position: currentState.position,
            parentMoveId: nil,
            currentDepth: 0,
            configuration: configuration,
            positionEvaluator: positionEvaluator,
            legalMoveGenerator: legalMoveGenerator,
            decider: decider,
            evaluationCache: evaluationCache
        )

        let bestMove = await decider.bestMove()

        let analyzedPositionCount = await decider.itemCount()
        let cachedPositionCount = await evaluationCache.itemCount()
        logDebug(
            """
            BEST MOVE: \(bestMove as Any? ?? "NO VALID MOVES FOUND :(")
            
            """,
            bench.checkpoint(),
            "\(analyzedPositionCount) analyzed positions, \(cachedPositionCount) cached positions",
            category: .engine
        )

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
        parentMoveId: MoveId?,
        currentDepth: Int,
        configuration: EngineConfiguration,
        positionEvaluator: PositionEvaluator,
        legalMoveGenerator: LegalMoveGenerator,
        decider: Decider,
        evaluationCache: EvaluationCache
    ) async {
        if currentDepth >= configuration.maxDepth {
            return
        }

        //logDebug("Analysis... Depth = \(currentDepth + 1) halfmoves", category: .engine)
        //logDebug(position, category: .engine)

        var movesToAnalyzeFurther = [(moveId: MoveId, posAfterMove: Position)]()

        do {
            let sideToMove = position.sideToMove

            let moves = legalMoveGenerator.generateLegalMoves(position, parentMoveId: parentMoveId)

            if currentDepth == 0 {
                await decider.set(zeroDepthMoves: moves)
            }

            movesToAnalyzeFurther.reserveCapacity(moves.count)
            var moveResults = [MoveResult]()
            moveResults.reserveCapacity(moves.count)
            var wasCheckmateFound = false
            let valueBeforeMove = ValueCalculatorImpl().calculate(position)[sideToMove]

            for move in moves {
                let posAfterMove = position.applied(move: move)

                let capturedValue: PieceValue
                if let capturedValueDuringMove = (move as? CaptureMove)?.captured.type.defaultValue {
                    capturedValue = capturedValueDuringMove
                } else if let capturedValueDuringMove = (move as? PromotionMove)?.captured?.type.defaultValue {
                    capturedValue = capturedValueDuringMove
                } else {
                    capturedValue = 0
                }

                let evaluation: PositionEvaluation = positionEvaluator.evaluate(posAfterMove)

//                let posFEN = posAfterMove.fenBoardString
//                if let cachedEvaluation = await evaluationCache.get(posFEN) {
//                    evaluation = cachedEvaluation
//                } else {
//                    evaluation = positionEvaluator.evaluate(posAfterMove)
//                    await evaluationCache.set(evaluation, for: posFEN)
//                }

                let repositionDelta = evaluation.values[sideToMove] - valueBeforeMove

                switch evaluation.state {
                case .kingCheckmated:
                    wasCheckmateFound = true

                    let result = MoveResult(
                        side: sideToMove,
                        move: move,
                        capturedValue: capturedValue,
                        repositionDelta: repositionDelta,
                        isEnemyKingChecked: true,
                        isEnemyKingCheckmated: true,
                        isEnemyKingStalemated: false,
                        isDraw: false,
                        depth: currentDepth
                    )
                    moveResults.append(result)

                case .kingChecked:
                    let result = MoveResult(
                        side: sideToMove,
                        move: move,
                        capturedValue: capturedValue,
                        repositionDelta: repositionDelta,
                        isEnemyKingChecked: true,
                        isEnemyKingCheckmated: false,
                        isEnemyKingStalemated: false,
                        isDraw: false,
                        depth: currentDepth
                    )
                    moveResults.append(result)
                    movesToAnalyzeFurther.append((move.id, posAfterMove))

                case .kingStalemated:
                    let result = MoveResult(
                        side: sideToMove,
                        move: move,
                        capturedValue: capturedValue,
                        repositionDelta: repositionDelta,
                        isEnemyKingChecked: false,
                        isEnemyKingCheckmated: false,
                        isEnemyKingStalemated: true,
                        isDraw: true,
                        depth: currentDepth
                    )
                    moveResults.append(result)

                case .draw:
                    let result = MoveResult(
                        side: sideToMove,
                        move: move,
                        capturedValue: capturedValue,
                        repositionDelta: repositionDelta,
                        isEnemyKingChecked: false,
                        isEnemyKingCheckmated: false,
                        isEnemyKingStalemated: false,
                        isDraw: true,
                        depth: currentDepth
                    )
                    moveResults.append(result)

                case .normal:
                    let result = MoveResult(
                        side: sideToMove,
                        move: move,
                        capturedValue: capturedValue,
                        repositionDelta: repositionDelta,
                        isEnemyKingChecked: false,
                        isEnemyKingCheckmated: false,
                        isEnemyKingStalemated: false,
                        isDraw: false,
                        depth: currentDepth
                    )
                    moveResults.append(result)
                    movesToAnalyzeFurther.append((move.id, posAfterMove))
                }
            }

            await decider.add(moveResults: moveResults)

            if wasCheckmateFound && !configuration.analyzeFurtherAfterCheckmateOnFirstDepth && currentDepth == 0 {
                return
            }
        }

        await withTaskGroup { group in
            for (moveId, posAfterMove) in movesToAnalyzeFurther {
                group.addTask {
                    await analyze(
                        position: posAfterMove,
                        parentMoveId: moveId,
                        currentDepth: currentDepth + 1,
                        configuration: configuration,
                        positionEvaluator: positionEvaluator,
                        legalMoveGenerator: legalMoveGenerator,
                        decider: decider,
                        evaluationCache: evaluationCache
                    )
                }
            }
        }
    }
}
