//
//  PositionEvaluator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public enum PositionValue: Equatable {
    case normal(advantage: PieceValue)
    case kingChecked(PieceColor)
    case kingCheckmated(PieceColor)
    case kingStalemated(PieceColor)
    case draw
    case invalid(reason: String)
}

public protocol PositionEvaluator: AnyObject {
    func evaluate(_ position: Position) -> PositionValue
}

public class PositionEvaluatorImpl: PositionEvaluator {
    let staticValueCalculator: ValueCalculator
    let possibleMoveGenerator: PossibleMoveGenerator

    public init(
        staticValueCalculator: ValueCalculator = ValueCalculatorImpl(),
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl()
    ) {
        self.staticValueCalculator = staticValueCalculator
        self.possibleMoveGenerator = possibleMoveGenerator
    }

    public func evaluate(_ position: Position) -> PositionValue {
        print(position)

        var kingsInCheck = Set<PieceColor>()
        var kingsInCheckmate = Set<PieceColor>()

        for kingColor in [PieceColor.white, .black] {
            if let kingCoordinate = position.kingCoordinate(kingColor) {
                var attackersPosition = position
                attackersPosition.turn = kingColor.opposite
                let attackerMovesWithCheck = possibleMoveGenerator.generateAllMoves(attackersPosition, parentMoveId: nil)
                    .filter { ($0 as? CaptureMove)?.to == kingCoordinate }

                if !attackerMovesWithCheck.isEmpty {
                    kingsInCheck.insert(kingColor)
                    logDebug("\(kingColor) king is in check!", category: .evaluator)
                    var defendersPosition = position
                    defendersPosition.turn = kingColor
                    let defenderMoves = possibleMoveGenerator.generateAllMoves(defendersPosition, parentMoveId: nil)
                    var stillInCheckCount = 0
                    for defenderMove in defenderMoves {
                        var positionAfterDefenderMove = defendersPosition.applied(move: defenderMove)
                        positionAfterDefenderMove.turn = kingColor.opposite
                        let sideToMoveKingCoordinateAfterDefenderMove = positionAfterDefenderMove.kingCoordinate(kingColor)
                        let attackerMovesWithCheckAfterDefenderMove = possibleMoveGenerator.generateAllMoves(
                            positionAfterDefenderMove,
                            parentMoveId: nil
                        )
                        .filter { ($0 as? CaptureMove)?.to == sideToMoveKingCoordinateAfterDefenderMove }

                        if !attackerMovesWithCheckAfterDefenderMove.isEmpty {
                            stillInCheckCount += 1
                        }
                    }
                    if stillInCheckCount == defenderMoves.count {
                        print("\(kingColor) king is in CHECKMATE!")
                        kingsInCheckmate.insert(kingColor)
                    }
                }
            }
        }

        if kingsInCheck.count > 1 {
            print("Invalid position: Both kings are in check!")
            return .invalid(reason: "Invalid position: Both kings are in check!")
        }
        if let color = kingsInCheckmate.first {
            return .kingCheckmated(color)
        }
        if let color = kingsInCheck.first {
            return .kingChecked(color)
        }

        let advantage = staticValueCalculator.calculate(position)
        return PositionValue.normal(advantage: advantage)
    }
}
