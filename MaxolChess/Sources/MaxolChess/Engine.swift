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

public struct EngineConfiguration {
    //    public var analisysLimit: AnalisysLimit = .depth(2)
    /// In halfmoves
    public let maxDepth: Int
    public let returnFirstCheckmateMove: Bool

    public init(maxDepth: Int = 2, returnFirstCheckmateMove: Bool = false) {
        self.maxDepth = maxDepth
        self.returnFirstCheckmateMove = returnFirstCheckmateMove
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

        await Self.analyze(position: currentState.position, parentMoveId: nil, currentDepth: 0, maxDepth: configuration.maxDepth, moveResultRepo: moveResultRepo)

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

    private static func analyze(position: Position, parentMoveId: MoveId?, currentDepth: Int, maxDepth: Int, moveResultRepo: MoveResultRepo) async {
        if currentDepth >= maxDepth {
            return
        }

        logDebug("Analysis... Depth = \(currentDepth + 1) halfmoves")
//        logDebug(position)

        let sideToMove = position.sideToMove
        let legalMoveGenerator = LegalMoveGeneratorImpl()
        let positionEvaluator = PositionEvaluatorImpl()
        let moves = legalMoveGenerator.generateLegalMoves(position, parentMoveId: parentMoveId)

        var movesToAnalyzeFurther = [(move: Move, posAfterMove: Position)]()

        for move in moves {
            await Task.yield()

            if parentMoveId == nil {
                await moveResultRepo.add(move: move)
            }

            let posAfterMove = position.applied(move: move)
            let gain = (move as? CaptureMove)?.captured.type.defaultValue ?? 0

            let evaluation = positionEvaluator.evaluate(posAfterMove)

            switch evaluation.state {
            case .kingCheckmated:
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
                await moveResultRepo.add(moveResult: result)
                if /*configuration.returnFirstCheckmateMove*/ true && currentDepth == 0 {
                    return
                }

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
                await moveResultRepo.add(moveResult: result)
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
                await moveResultRepo.add(moveResult: result)

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
                await moveResultRepo.add(moveResult: result)

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
                await moveResultRepo.add(moveResult: result)
                movesToAnalyzeFurther.append((move, posAfterMove))
            }
        }

        await withTaskGroup { group in
            for (move, posAfterMove) in movesToAnalyzeFurther {
                group.addTask {
                    await analyze(position: posAfterMove, parentMoveId: move.id, currentDepth: currentDepth + 1, maxDepth: maxDepth, moveResultRepo: moveResultRepo)
                }
            }
        }
    }
}
