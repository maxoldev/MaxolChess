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
    private let positionEvaluator: PositionEvaluator

    public init(
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl(),
        positionEvaluator: PositionEvaluator = PositionEvaluatorImpl()
    ) {
        self.possibleMoveGenerator = possibleMoveGenerator
        self.positionEvaluator = positionEvaluator
    }

    public func generateLegalMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.sideToMove

        var legalMoves = [Move]()

        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = position.board[coordinate], piece.color == sideToMove {
                let allMoves = possibleMoveGenerator.generateAllMoves(position, from: coordinate, parentMoveId: parentMoveId)
                var possibleMoves = [Move]()
                for move in allMoves {
                    var posAfterMove = position.applied(move: move)
                    posAfterMove.sideToMove = sideToMove

                    let evaluation = positionEvaluator.evaluate(posAfterMove)

                    if evaluation.state != .kingChecked && evaluation.state != .kingCheckmated {
                        possibleMoves.append(move)
                    }
                }
                legalMoves.append(contentsOf: possibleMoves)
            }
        }

        return legalMoves
    }
}
