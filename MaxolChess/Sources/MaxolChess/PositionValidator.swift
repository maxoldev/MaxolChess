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

public protocol PositionValidator {
    func validate(_ position: Position) -> PositionValidatorResult
}

public final class PositionValidatorImpl: PositionValidator {
    let attackChecker: AttackChecker

    public init(attackChecker: AttackChecker = AttackCheckerImpl()) {
        self.attackChecker = attackChecker
    }

    public func validate(_ position: Position) -> PositionValidatorResult {
        var kingsInCheck = Set<PieceColor>()

        for kingColor in [PieceColor.white, .black] {
            if let kingCoordinate = position.kingCoordinate(kingColor) {
                let isKingAttacked = attackChecker.areCoordinates([kingCoordinate], attackedBy: kingColor.opposite, board: position.board)

                if isKingAttacked {
                    kingsInCheck.insert(kingColor)
                }
            }
        }

        if kingsInCheck.count > 1 {
            return .invalid2KingsInCheck
        }

        return .valid
    }
}
