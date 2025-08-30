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

public class EngineImpl: Engine {
    private let configuration: EngineConfiguration
    private let valueCalculator: ValueCalculator
    private let positionEvaluator: PositionEvaluator
    private let legalMoveGenerator: LegalMoveGenerator

    private var currentState: GameState
    private let moveResultRepo = MoveResultRepo()

    public init(
        configuration: EngineConfiguration = EngineConfiguration(),
        valueCalculator: ValueCalculator = ValueCalculatorImpl(),
        positionEvaluator: PositionEvaluator = PositionEvaluatorImpl(),
        legalMoveGenerator: LegalMoveGenerator = LegalMoveGeneratorImpl(),
        gameState: GameState = GameState(position: Position.start)
    ) {
        self.configuration = configuration
        self.valueCalculator = valueCalculator
        self.positionEvaluator = positionEvaluator
        self.legalMoveGenerator = legalMoveGenerator
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
        logDebug(currentState.position, category: .engine)
        let bench = Benchmark()

        await moveResultRepo.clear()

        await Self.analyze(
            position: currentState.position,
            parentMoveId: nil,
            currentDepth: 0,
            configuration: configuration,
            moveResultRepo: moveResultRepo
        )

        let bestMove = await moveResultRepo.bestMove()
        logDebug("BEST MOVE:", bestMove, bench.checkpoint(), category: .engine)
        return bestMove
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
        moveResultRepo: MoveResultRepo
    ) async {
        if currentDepth >= configuration.maxDepth {
            return
        }

        logDebug("Analysis... Depth = \(currentDepth + 1) halfmoves")
        //logDebug(position)

        let sideToMove = position.sideToMove
        let legalMoveGenerator = LegalMoveGeneratorImpl()
        let positionEvaluator = PositionEvaluatorImpl()
        let moves = legalMoveGenerator.generateLegalMoves(position, parentMoveId: parentMoveId)

        if currentDepth == 0 {
            await moveResultRepo.set(zeroDepthMoves: moves)
        }

        var movesToAnalyzeFurther = [(move: Move, posAfterMove: Position)]()
        var moveResults = [MoveResult]()
        var wasCheckmateFound = false

        for move in moves {
            await Task.yield()

            let posAfterMove = position.applied(move: move)
            // TODO: handle promotion capture
            let gain = (move as? CaptureMove)?.captured.type.defaultValue ?? 0

            let evaluation = positionEvaluator.evaluate(posAfterMove)

            switch evaluation.state {
            case .kingCheckmated:
                wasCheckmateFound = true

                let result = MoveResult(
                    side: sideToMove,
                    move: move,
                    depth: currentDepth,
                    gain: gain,
                    isEnemyKingChecked: true,
                    isEnemyKingCheckmated: true,
                    isEnemyKingStalemated: false,
                    isDraw: false
                )
                moveResults.append(result)

            case .kingChecked:
                let result = MoveResult(
                    side: sideToMove,
                    move: move,
                    depth: currentDepth,
                    gain: gain,
                    isEnemyKingChecked: true,
                    isEnemyKingCheckmated: false,
                    isEnemyKingStalemated: false,
                    isDraw: false
                )
                moveResults.append(result)
                movesToAnalyzeFurther.append((move, posAfterMove))

            case .kingStalemated:
                let result = MoveResult(
                    side: sideToMove,
                    move: move,
                    depth: currentDepth,
                    gain: gain,
                    isEnemyKingChecked: false,
                    isEnemyKingCheckmated: false,
                    isEnemyKingStalemated: true,
                    isDraw: true
                )
                moveResults.append(result)

            case .draw:
                let result = MoveResult(
                    side: sideToMove,
                    move: move,
                    depth: currentDepth,
                    gain: gain,
                    isEnemyKingChecked: false,
                    isEnemyKingCheckmated: false,
                    isEnemyKingStalemated: false,
                    isDraw: true
                )
                moveResults.append(result)

            case .normal:
                let result = MoveResult(
                    side: sideToMove,
                    move: move,
                    depth: currentDepth,
                    gain: gain,
                    isEnemyKingChecked: false,
                    isEnemyKingCheckmated: false,
                    isEnemyKingStalemated: false,
                    isDraw: false
                )
                moveResults.append(result)
                movesToAnalyzeFurther.append((move, posAfterMove))
            }
        }

        await moveResultRepo.add(moveResults: moveResults)

        if wasCheckmateFound && !configuration.analyzeFurtherAfterCheckmateOnFirstDepth && currentDepth == 0 {
            return
        }

        await withTaskGroup { group in
            for (move, posAfterMove) in movesToAnalyzeFurther {
                group.addTask {
                    await analyze(
                        position: posAfterMove,
                        parentMoveId: move.id,
                        currentDepth: currentDepth + 1,
                        configuration: configuration,
                        moveResultRepo: moveResultRepo
                    )
                }
            }
        }
    }
}
