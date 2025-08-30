//
//  PositionChecker.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 23.08.2025.
//

public enum PositionValidatorResult: Equatable {
    case valid
    case invalid2KingsInCheck
}

public protocol PositionValidator: AnyObject {
    func validate(_ position: Position) -> PositionValidatorResult
}

public final class PositionValidatorImpl: PositionValidator {
    let possibleMoveGenerator: PossibleMoveGenerator

    public init(possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl()) {
        self.possibleMoveGenerator = possibleMoveGenerator
    }

    public func validate(_ position: Position) -> PositionValidatorResult {
        var kingsInCheck = Set<PieceColor>()

        for kingColor in [PieceColor.white, .black] {
            if let kingCoordinate = position.kingCoordinate(kingColor) {
                var attackersPosition = position
                attackersPosition.sideToMove = kingColor.opposite
                let attackerMovesWithCheck = possibleMoveGenerator.generateAllMoves(attackersPosition, parentMoveId: nil)
                    .filter { ($0 as? CaptureMove)?.to == kingCoordinate }

                if !attackerMovesWithCheck.isEmpty {
                    kingsInCheck.insert(kingColor)
                    continue
                }
            }
        }

        if kingsInCheck.count > 1 {
            return .invalid2KingsInCheck
        }
        return .valid
    }
}
