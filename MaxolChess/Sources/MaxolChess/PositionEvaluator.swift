//
//  PositionEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct PositionEvaluation {
    public enum State {
        case normal
        case kingChecked
        case kingCheckmated
        case kingStalemated
        case draw
    }
    public let state: State
    public let values: ValueCalculation
}

public protocol PositionEvaluator: AnyObject {
    func evaluate(_ position: Position) -> PositionEvaluation
}

public class PositionEvaluatorImpl: PositionEvaluator {
    private let valueCalculator: ValueCalculator
    private let possibleMoveGenerator: PossibleMoveGenerator

    public init(
        valueCalculator: ValueCalculator = ValueCalculatorImpl(),
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl()
    ) {
        self.valueCalculator = valueCalculator
        self.possibleMoveGenerator = possibleMoveGenerator
    }

    public func evaluate(_ position: Position) -> PositionEvaluation {
        var isKingChecked = false
        var isKingCheckedmated = false

        if let kingCoordinate = position.kingCoordinate(position.sideToMove) {
            let attackersPosition = position.opposite
            // Check all moves that targeted to the king's square
            // These are "attacks" on the king
            let attackerMovesWithCheck = possibleMoveGenerator.generateAllMoves(attackersPosition)
                .filter { ($0 as? CaptureMove)?.to == kingCoordinate || ($0 as? PromotionMove)?.to == kingCoordinate}

            if !attackerMovesWithCheck.isEmpty {
                isKingChecked = true

                let defenderMoves = possibleMoveGenerator.generateAllMoves(position)
                var stillInCheckCount = 0
                for defenderMove in defenderMoves {
                    let positionAfterDefenderMove = position.applied(move: defenderMove)
                    let sideToMoveKingCoordinateAfterDefenderMove = positionAfterDefenderMove.kingCoordinate(position.sideToMove)
                    let attackerMovesWithCheckAfterDefenderMove = possibleMoveGenerator.generateAllMoves(positionAfterDefenderMove)
                        .filter { ($0 as? CaptureMove)?.to == sideToMoveKingCoordinateAfterDefenderMove || ($0 as? PromotionMove)?.to == sideToMoveKingCoordinateAfterDefenderMove }

                    if !attackerMovesWithCheckAfterDefenderMove.isEmpty {
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
