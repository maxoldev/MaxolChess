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

        if let kingCoordinate = position.kingCoordinate(sideToMove) {
            let attackersPosition = position.opposite
            let opponentMoves = possibleMoveGenerator.generateAllMoves(attackersPosition)
            // Check all moves that targeted to the king's square
            // These are "attacks" on the king
            let attackerMovesWithCheck = opponentMoves
                .filter { ($0 as? CaptureMove)?.to == kingCoordinate }
            let isNoCheck = attackerMovesWithCheck.isEmpty
            if isNoCheck {
                legalMoves.append(contentsOf: generateCastlingMoves(position, parentMoveId: parentMoveId, opponentMoves: opponentMoves))
            }
        }

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

    public func generateCastlingMoves(_ position: Position, parentMoveId: MoveId?, opponentMoves: [Move]) -> [Move] {
        let sideToMove = position.sideToMove
        var castlingMoves = [Move]()

        if !position.castlingRights[sideToMove]!.isEmpty {
            let kingCoord = position.kingCoordinate(sideToMove)!

            if position.castlingRights[sideToMove]!.contains(.kingSide)
                && position.board[kingCoord.advancedBy(1, 0)!] == nil
                && position.board[kingCoord.advancedBy(2, 0)!] == nil
                && opponentMoves.filter({ ($0 as? RepositionMove)?.to == kingCoord.advancedBy(1, 0)! || ($0 as? RepositionMove)?.to == kingCoord.advancedBy(2, 0)! }).isEmpty
            {
                castlingMoves.append(CastlingMove(parentMoveId: parentMoveId, side: .kingSide))
            }
            if position.castlingRights[sideToMove]!.contains(.queenSide)
                && position.board[kingCoord.advancedBy(-1, 0)!] == nil
                && position.board[kingCoord.advancedBy(-2, 0)!] == nil
                && position.board[kingCoord.advancedBy(-3, 0)!] == nil
                && opponentMoves.filter({ ($0 as? RepositionMove)?.to == kingCoord.advancedBy(-1, 0)! || ($0 as? RepositionMove)?.to == kingCoord.advancedBy(-2, 0)!}).isEmpty
            {
                castlingMoves.append(CastlingMove(parentMoveId: parentMoveId, side: .queenSide))
            }
        }
        return castlingMoves
    }
}
