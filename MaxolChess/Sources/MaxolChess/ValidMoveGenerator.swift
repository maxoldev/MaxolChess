//
//  ValidMoveGenerator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

public protocol ValidMoveGenerator {
    /// Only valid moves excluding not possible due to check to own king
    func generateValidMoves(_ position: Position, parentMoveId: MoveId?) -> [Move]
}

public class ValidMoveGeneratorImpl: ValidMoveGenerator {
    private let possibleMoveGenerator: PossibleMoveGenerator
    private let staticPositionEvaluator: StaticPositionEvaluator

    public init(
        possibleMoveGenerator: PossibleMoveGenerator = PossibleMoveGeneratorImpl(),
        staticPositionEvaluator: StaticPositionEvaluator = StaticPositionEvaluatorImpl()
    ) {
        self.possibleMoveGenerator = possibleMoveGenerator
        self.staticPositionEvaluator = staticPositionEvaluator
    }

    public func generateValidMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.turn

        var validMoves = [Move]()

        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = position.board[coordinate], piece.color == sideToMove {
                let allMoves = possibleMoveGenerator.generateAllMoves(position, from: coordinate, parentMoveId: parentMoveId)
                print(allMoves)
                var possibleMoves = [Move]()
                for move in allMoves {
                    let posAfterMove = position.applied(move: move)
                    let evaluation = staticPositionEvaluator.evaluate(posAfterMove)
                    print(evaluation)
                    if evaluation != .kingChecked(sideToMove) && evaluation != .kingCheckmated(sideToMove) {
                        possibleMoves.append(move)
                    }
                }
                validMoves.append(contentsOf: possibleMoves)
            }
        }

        return validMoves
    }
}
