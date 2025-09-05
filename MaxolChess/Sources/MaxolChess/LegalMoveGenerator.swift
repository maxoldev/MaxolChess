//
//  LegalMoveGenerator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

public protocol LegalMoveGenerator: Sendable {
    /// Only valid moves excluding not possible due to check to own king
    func generateLegalMoves(_ position: Position, parentMoveId: MoveId?) -> [Move]
}

public final class LegalMoveGeneratorImpl: LegalMoveGenerator {
    private let possibleMoveGenerator: PossibleMoveGenerator
    private let attackChecker: AttackChecker

    public init(
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl(),
        attackChecker: AttackChecker = AttackCheckerImpl()
    ) {
        self.possibleMoveGenerator = possibleMoveGenerator
        self.attackChecker = attackChecker
    }

    public func generateLegalMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.sideToMove

        var legalMoves = [Move]()

        if let kingCoordinate = position.kingCoordinate(sideToMove) {
            let isKingAttacked = attackChecker.isCoordinate(kingCoordinate, attackedBy: sideToMove.opposite, board: position.board)
            if !isKingAttacked {
                legalMoves.append(contentsOf: generateCastlingMoves(position, parentMoveId: parentMoveId))
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
                        let isKingAttacked = attackChecker.isCoordinate(
                            kingCoordinate,
                            attackedBy: sideToMove.opposite,
                            board: posAfterMove.board
                        )
                        if !isKingAttacked {
                            legalPieceMoves.append(move)
                        }
                    }
                }
                legalMoves.append(contentsOf: legalPieceMoves)
            }
        }

        return legalMoves
    }

    public func generateCastlingMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.sideToMove
        var castlingMoves = [Move]()

        if !position.castlingRights[sideToMove]!.isEmpty {
            let kingCoord = position.kingCoordinate(sideToMove)!

            do {
                let interCoord1 = kingCoord.advancedBy(1, 0)!
                let interCoord2 = kingCoord.advancedBy(2, 0)!
                if position.castlingRights[sideToMove]!.contains(.kingSide)
                    && position.board[interCoord1] == nil
                    && position.board[interCoord2] == nil
                    && !attackChecker.areCoordinates([interCoord1, interCoord2], attackedBy: sideToMove.opposite, board: position.board)
                {
                    castlingMoves.append(CastlingMove(parentMoveId: parentMoveId, side: .kingSide))
                }
            }
            let interCoord1 = kingCoord.advancedBy(-1, 0)!
            let interCoord2 = kingCoord.advancedBy(-2, 0)!
            let interCoord3 = kingCoord.advancedBy(-3, 0)!
            if position.castlingRights[sideToMove]!.contains(.queenSide)
                && position.board[interCoord1] == nil
                && position.board[interCoord2] == nil
                && position.board[interCoord3] == nil
                && !attackChecker.areCoordinates(
                    [interCoord1, interCoord2, interCoord3],
                    attackedBy: sideToMove.opposite,
                    board: position.board
                )
            {
                castlingMoves.append(CastlingMove(parentMoveId: parentMoveId, side: .queenSide))
            }
        }
        return castlingMoves
    }
}
