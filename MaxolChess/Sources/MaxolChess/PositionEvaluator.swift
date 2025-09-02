//
//  PositionEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct PositionEvaluation: Sendable {
    public enum State: Sendable {
        case normal
        case kingChecked
        case kingCheckmated
        case kingStalemated
        case draw
    }
    public let state: State
    public let values: ValueCalculation
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
        var isKingCheckedmated = false

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
                    isKingCheckedmated = true
                }
            }
        }

        let values = valueCalculator.calculate(position)

        if isKingCheckedmated {
            return PositionEvaluation(state: .kingCheckmated, values: values)
        }

        if isKingChecked {
            return PositionEvaluation(state: .kingChecked, values: values)
        }

        return PositionEvaluation(state: .normal, values: values)
    }
}
