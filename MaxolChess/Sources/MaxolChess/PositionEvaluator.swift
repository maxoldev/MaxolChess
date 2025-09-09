//
//  PositionEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct PositionEvaluation: Sendable {
    public enum State: Sendable {
        case `default`
        case kingChecked
        case kingCheckmated
        case kingStalemated
        case draw
    }
    fileprivate let state: State
    public let advantage: Double
}

extension PositionEvaluation.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .default: "Default"
        case .kingChecked: "+Check"
        case .kingCheckmated: "#Checkmate"
        case .kingStalemated: "Stalemate"
        case .draw: "Draw"
        }
    }
}

extension PositionEvaluation: CustomStringConvertible {
    public var description: String {
        "\(state), Advantage = \(advantage)"
    }
}

public protocol PositionEvaluator: AnyObject, Sendable {
    func evaluate(_ position: Position) -> PositionEvaluation
}

public final class PositionEvaluatorImpl: PositionEvaluator {
    private let valueCalculator: ValueCalculator
    private let possibleMoveGenerator: PossibleMoveGenerator
    private let attackChecker: AttackChecker

    public init(
        valueCalculator: ValueCalculator = ValueCalculatorImpl(),
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl(),
        attackChecker: AttackChecker = AttackCheckerImpl()
    ) {
        self.valueCalculator = valueCalculator
        self.possibleMoveGenerator = possibleMoveGenerator
        self.attackChecker = attackChecker
    }

    public func evaluate(_ position: Position) -> PositionEvaluation {
        var isKingChecked = false
        var isKingCheckmated = false

        if let kingCoordinate = position.kingCoordinate(position.sideToMove) {
            let isKingAttacked = attackChecker.isCoordinate(kingCoordinate, attackedBy: position.sideToMove.opposite, board: position.board)

            if isKingAttacked {
                isKingChecked = true

                let defenderMoves = possibleMoveGenerator.generateAllMoves(position)
                var stillInCheckCount = 0
                for defenderMove in defenderMoves {
                    let positionAfterDefenderMove = position.applied(move: defenderMove)
                    let kingCoordinateAfterDefenderMove = positionAfterDefenderMove.kingCoordinate(position.sideToMove)!
                    let isKingAttacked = attackChecker.isCoordinate(
                        kingCoordinateAfterDefenderMove,
                        attackedBy: position.sideToMove.opposite,
                        board: positionAfterDefenderMove.board
                    )

                    if isKingAttacked {
                        stillInCheckCount += 1
                    }
                }
                if stillInCheckCount == defenderMoves.count {
                    isKingCheckmated = true
                }
            }
        }

        let values = valueCalculator.calculate(position)

        let evaluation: PositionEvaluation

        let valueDiff = values.white - values.black

        if isKingCheckmated {
            let advantage = position.sideToMove == .white ? -Const.Evaluation.checkmate : Const.Evaluation.checkmate
            evaluation = PositionEvaluation(state: .kingCheckmated, advantage: advantage)
        } else if isKingChecked {
            let advantage = valueDiff + (position.sideToMove == .white ? -Const.Evaluation.check : Const.Evaluation.check)
            evaluation = PositionEvaluation(state: .kingChecked, advantage: advantage)
        } else {
            let advantage = valueDiff
            evaluation = PositionEvaluation(state: .default, advantage: advantage)
        }

        return evaluation
    }
}
