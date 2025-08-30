//
//  LegalMoveGenerator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

public protocol LegalMoveGenerator {
    /// Only valid moves excluding not possible due to check to own king
    func generateLegalMoves(_ position: Position, parentMoveId: MoveId?) -> [Move]
}

public class LegalMoveGeneratorImpl: LegalMoveGenerator {
    private let possibleMoveGenerator: PossibleMoveGenerator

    public init(possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl()) {
        self.possibleMoveGenerator = possibleMoveGenerator
    }

    public func generateLegalMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.sideToMove

        var legalMoves = [Move]()

        for i in 0..<Const.boardSquareCount {
            if let piece = position.board[i], piece.color == sideToMove {
                let allPieceMoves = possibleMoveGenerator.generateAllMoves(position, from: Coordinate(i), parentMoveId: parentMoveId)
                var legalPieceMoves = [Move]()
                for move in allPieceMoves {
                    var posAfterMove = position.applied(move: move)
                    posAfterMove.sideToMove = sideToMove

                    if let kingCoordinate = posAfterMove.kingCoordinate(sideToMove) {
                        let attackersPosition = posAfterMove.opposite
                        // Check all possible moves that targeted to the king's square
                        // These are "attacks" on the king
                        let attackerMovesWithCheck = possibleMoveGenerator.generateAllMoves(attackersPosition)
                            .filter { ($0 as? CaptureMove)?.to == kingCoordinate }

                        let isNoCheck = attackerMovesWithCheck.isEmpty
                        if isNoCheck {
                            legalPieceMoves.append(move)
                        }
                    }
                }
                legalMoves.append(contentsOf: legalPieceMoves)
            }
        }

        return legalMoves
    }
}
