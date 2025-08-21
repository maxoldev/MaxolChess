//
//  PossibleMoveGenerator.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 16.08.2025.
//

public protocol PossibleMoveGenerator {
    /// Including not possible due to check to own king
    func generateAllMoves(_ position: Position, parentMoveId: MoveId?) -> [Move]
    /// Including not possible due to check to own king
    func generateAllMoves(_ position: Position, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move]
}

public class PossibleMoveGeneratorImpl: PossibleMoveGenerator {
    public init() {
    }

    public func generateAllMoves(_ position: Position, parentMoveId: MoveId?) -> [Move] {
        let sideToMove = position.turn

        var moves = [Move]()

        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = position.board[coordinate], piece.color == sideToMove {
                let pieceMoves = generateAllMoves(position, from: coordinate, parentMoveId: parentMoveId)
                moves.append(contentsOf: pieceMoves)
            }
        }

        return moves
    }

    public func generateAllMoves(_ position: Position, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        guard let piece = position.board[coordinate] else {
            return []
        }

        switch piece.type {
        case .pawn:
            return pawnMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)

        case .knight:
            return knightMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)

        case .bishop:
            return bishopMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)

        case .rook:
            return rookMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)

        case .queen:
            return queenMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)

        case .king:
            return kingMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)
        }
    }

    private func pawnMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        var moves = [Move]()

        let moveDirection = piece.color == .white ? 1 : -1

        // Capture
        if let newCoordinate = coordinate.advancedBy(-1, moveDirection) {
            if let other = position.board[newCoordinate], other.color != piece.color {
                moves.append(CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other))
            }
        }
        if let newCoordinate = coordinate.advancedBy(1, moveDirection) {
            if let other = position.board[newCoordinate], other.color != piece.color {
                moves.append(CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other))
            }
        }

        // 1-square move
        if let newCoordinate = coordinate.advancedBy(0, moveDirection) {
            if position.board[newCoordinate] == nil {
                moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))

                // 2-square move
                let isInStartPosition =
                    piece.color == .white && coordinate.y == 1
                    || piece.color == .black && coordinate.y == Const.baseBoardSize - 2
                if isInStartPosition {
                    if let newCoordinate = coordinate.advancedBy(0, 2 * moveDirection) {
                        if position.board[newCoordinate] == nil {
                            moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))
                        }
                    }
                }
            }
        }

        return moves
    }

    private func knightMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        var moves: [Move] = []

        // TODO: make order to consider equal for the both sides
        let advances: [(Int, Int)] = [
            (-2, 1),
            (-1, 2),
            (1, 2),
            (2, 1),
            (2, -1),
            (1, -2),
            (-1, -2),
            (-2, -1),
        ]

        for (dx, dy) in advances {
            if let newCoordinate = coordinate.advancedBy(dx, dy) {
                if let other = position.board[newCoordinate] {
                    if other.color != piece.color {
                        moves.append(
                            CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other)
                        )
                    }
                } else {
                    moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))
                }
            }
        }

        return moves
    }

    private func bishopMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        var moves: [Move] = []

        // TODO: make order to consider equal for the both sides
        let advances: [(Int, Int)] = [
            (-1, 1),
            (1, 1),
            (1, -1),
            (-1, -1),
        ]

        for (dx, dy) in advances {
            var count = 1
            repeat {
                defer {
                    count += 1
                }

                guard let newCoordinate = coordinate.advancedBy(dx * count, dy * count) else {
                    break
                }

                if let other = position.board[newCoordinate] {
                    if other.color != piece.color {
                        moves.append(
                            CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other)
                        )
                    }

                    break
                } else {
                    moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))
                }
            } while true
        }

        return moves
    }

    private func rookMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        var moves: [Move] = []

        // TODO: make order to consider equal for the both sides
        let advances: [(Int, Int)] = [
            (-1, 0),
            (0, 1),
            (1, 0),
            (0, -1),
        ]

        for (dx, dy) in advances {
            var count = 1
            repeat {
                guard let newCoordinate = coordinate.advancedBy(dx * count, dy * count) else {
                    break
                }

                if let other = position.board[newCoordinate] {
                    if other.color != piece.color {
                        moves.append(
                            CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other)
                        )
                    }

                    break
                } else {
                    moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))
                }

                count += 1
            } while true
        }

        return moves
    }

    private func queenMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        let moves =
            rookMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)
            + bishopMoves(position, piece: piece, from: coordinate, parentMoveId: parentMoveId)
        return moves
    }

    private func kingMoves(_ position: Position, piece: Piece, from coordinate: Coordinate, parentMoveId: MoveId?) -> [Move] {
        var moves: [Move] = []

        // TODO: make order to consider equal for the both sides
        let advances: [(Int, Int)] = [
            (-1, 0),
            (-1, 1),
            (0, 1),
            (1, 1),
            (1, 0),
            (1, -1),
            (0, -1),
            (-1, -1),
        ]

        for (dx, dy) in advances {
            if let newCoordinate = coordinate.advancedBy(dx, dy) {
                if let oppositeKingCoordinate = position.kingCoordinate(piece.color.opposite) {
                    if newCoordinate.within1SquareOf(oppositeKingCoordinate) {
                        continue
                    }
                }
                if let other = position.board[newCoordinate] {
                    if other.color != piece.color {
                        moves.append(
                            CaptureMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate, capture: other)
                        )
                    }
                } else {
                    moves.append(RepositionMove(parentMoveId: parentMoveId, piece: piece, from: coordinate, to: newCoordinate))
                }
            }
        }

        return moves
    }
}
