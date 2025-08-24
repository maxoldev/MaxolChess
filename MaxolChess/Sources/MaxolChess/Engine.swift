//
//  Engine.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct GameState {
    public var ourSide: PieceColor
    public var position: Position
    public var playedMoves: [Move] = []

    public init(ourSide: PieceColor, position: Position, previousMoves: [Move] = []) {
        self.ourSide = ourSide
        self.position = position
        self.playedMoves = previousMoves
    }
}

public enum AnalisysLimit {
    /// Seconds
    case time(Double)
    /// In 2 halfmoves
    case depth(Int)
}

public struct EngineConfiguration {
    public var analisysLimit: AnalisysLimit = .depth(2)

    public init() {
    }
}

public protocol Engine {
    func getCurrentState() -> GameState
    func setCurrentState(_ state: GameState)

    func calculateOurBestMove() async -> Move?
    func setOurMove(_ move: Move)
    func setOpponentsMove(_ move: Move)

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
        gameState: GameState = GameState(ourSide: .white, position: Position.start)
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

    public func calculateOurBestMove() async -> Move? {
        logDebug(currentState.position, category: .engine)
        let bench = Benchmark()

        let moves = legalMoveGenerator.generateLegalMoves(currentState.position, parentMoveId: nil)
        var movesToConsider: [Move] = []
        var invalidResultMovesCount = 0

        for move in moves {
            let newPosition = currentState.position.applied(move: move)
            let result = positionEvaluator.evaluate(newPosition)

            switch result {
            case let .kingCheckmated(side):
                if side == currentState.ourSide {
                    continue
                } else {
                    logDebug("BEST MOVE: \(move) \(bench.checkpoint())", category: .engine)
                    return move
                }

            case let .kingChecked(side):
                if side == currentState.ourSide {
                    continue
                } else {
                    movesToConsider.append(move)
                }

            case .draw:
                fallthrough
            case .kingStalemated(_):
                fallthrough
            case .normal(_):
                movesToConsider.append(move)

            case let .invalid(reason):
                print(reason)
                invalidResultMovesCount += 1
            }
        }

        if invalidResultMovesCount == moves.count {
            logDebug("NO VALID MOVES🚫 \(bench.checkpoint())", category: .engine)
            return nil
        }

        await moveResultRepo.clear()

        for move in movesToConsider {
            await analyze(move: move, positionBeforeMove: currentState.position)
        }

        let bestMoveId = await moveResultRepo.bestMoveId(for: currentState.ourSide)
        let bestMove = movesToConsider.first(where: { $0.id == bestMoveId })
        logDebug("BEST MOVE:", bestMove, bench.checkpoint(), category: .engine)
        return bestMove
    }
    
    public func setOurMove(_ move: Move) {
        apply(move: move)
//        let evaluation = staticPositionEvaluator.evaluate(positionAfterMove)
    }

    public func setOpponentsMove(_ move: Move) {
        apply(move: move)
//        let evaluation = staticPositionEvaluator.evaluate(positionAfterMove)
    }

    public func updateConfiguration(_ configuration: EngineConfiguration) {
        fatalError()
    }

    // MARK: - Private
    private func apply(move: Move) {
        let positionAfterMove = currentState.position.applied(move: move)
        currentState.position = positionAfterMove
        currentState.playedMoves.append(move)
    }

    private func analyze(move: Move, positionBeforeMove: Position) async {
        var newPosition = positionBeforeMove.applied(move: move)
        newPosition.turn = currentState.ourSide.opposite
        let opponentMoves = legalMoveGenerator.generateLegalMoves(newPosition, parentMoveId: move.id)

        for opponentMove in opponentMoves {
            await Task.yield()

            let posAfterOpponentMove = newPosition.applied(move: opponentMove)
            let result = positionEvaluator.evaluate(posAfterOpponentMove)

            switch result {
            case let .kingCheckmated(side):
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: side == .white ? -1000 : 1000)
                await moveResultRepo.moveResultReceived(result)

            case let .kingChecked(side):
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: side == .white ? -100 : 100)
                await moveResultRepo.moveResultReceived(result)

            case .draw:
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: 0)
                await moveResultRepo.moveResultReceived(result)

            case let .kingStalemated(side):
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: 0)
                await moveResultRepo.moveResultReceived(result)

            case let .invalid(reason):
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: currentState.ourSide == .white ? 1000 : -1000)
                await moveResultRepo.moveResultReceived(result)

            case let .normal(advantage):
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, advantage: advantage)
                await moveResultRepo.moveResultReceived(result)
            }
        }
    }
}
