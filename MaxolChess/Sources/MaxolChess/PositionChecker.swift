//
//  PositionChecker.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 23.08.2025.
//

public enum PositionCheckerResult: Equatable {
    case valid
    case invalid2KingsInCheck
}

public protocol PositionChecker: AnyObject {
    func check(_ position: Position) -> PositionCheckerResult
}

public class PositionCheckerImpl: PositionChecker {
    let possibleMoveGenerator: PossibleMoveGenerator

    public init(possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl()) {
        self.possibleMoveGenerator = possibleMoveGenerator
    }

    public func check(_ position: Position) -> PositionCheckerResult {
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
