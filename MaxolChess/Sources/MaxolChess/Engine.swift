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
    private let staticValueEvaluator: StaticValueCalculator
    private let staticPositionEvaluator: StaticPositionEvaluator
    private let validMoveGenerator: ValidMoveGenerator

    private var currentState: GameState
    private let moveResultRepo = MoveResultRepo()

    public init(
        configuration: EngineConfiguration = EngineConfiguration(),
        staticValueEvaluator: StaticValueCalculator = StaticValueCalculatorImpl(),
        staticPositionEvaluator: StaticPositionEvaluator = StaticPositionEvaluatorImpl(),
        validMoveGenerator: ValidMoveGenerator = ValidMoveGeneratorImpl(),
        gameState: GameState = GameState(ourSide: .white, position: Position.start)
    ) {
        self.configuration = configuration
        self.staticValueEvaluator = staticValueEvaluator
        self.staticPositionEvaluator = staticPositionEvaluator
        self.validMoveGenerator = validMoveGenerator
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
        print(currentState.position)
        let validMoves = validMoveGenerator.generateValidMoves(currentState.position, parentMoveId: nil)
        print(validMoves)
        var checkMovesToConsider: [Move] = []
        var stalemateMovesToConsider: [Move] = []
        var normalMovesToConsider: [Move] = []
        var drawMoves: [Move] = []
        var invalidResultMovesCount = 0

        var maxAdvantage = -100000.0

        for move in validMoves {
            let newPosition = currentState.position.applied(move: move)
            let result = staticPositionEvaluator.evaluate(newPosition)
            switch result {
            case let .kingCheckmated(side):
                if side == currentState.ourSide {
                    continue
                } else {
                    return move
                }

            case let .kingChecked(side):
                if side == currentState.ourSide {
                    continue
                } else {
                    checkMovesToConsider.append(move)
                }

            case .draw:
                drawMoves.append(move)

            case let .kingStalemated(side):
                stalemateMovesToConsider.append(move)

            case let .invalid(reason):
                print(reason)
                invalidResultMovesCount += 1

            case let .normal(advantage):
                if advantage > maxAdvantage {
                    maxAdvantage = advantage
                    normalMovesToConsider.append(move)
                }
                let result = MoveResult(moveId: move.id, parentMoveId: move.parentMoveId, depth: 0, gain: <#T##Double#>, loss: <#T##Double#>, staticCalculationValue: advantage, gainMaxPotential: <#T##Double#>, lossMaxPotential: <#T##Double#>)
                await moveResultRepo.moveResultReceived(result)
            }
        }

        if invalidResultMovesCount == validMoves.count {
            // No valid moves
            return nil
        }
        
        let captureMovesToConsider: [Move] = normalMovesToConsider.filter { $0 is CaptureMove }
        var movesToConsider = checkMovesToConsider + captureMovesToConsider + normalMovesToConsider
        if movesToConsider.isEmpty {
            movesToConsider = drawMoves
        }
        if movesToConsider.isEmpty {
            movesToConsider = stalemateMovesToConsider
        }

        print(movesToConsider.first as Any)
        return movesToConsider.first
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

    private func analyze(move: Move) {
        let validMoves = validMoveGenerator.generateValidMoves(currentState.position, parentMoveId: nil)
        let newPosition = currentState.position.applied(move: move)
        let result = staticPositionEvaluator.evaluate(newPosition)

    }
}
