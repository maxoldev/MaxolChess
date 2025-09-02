//
//  AttackChecker.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 30.08.2025.
//

public protocol AttackChecker: Sendable {
    func isCoordinate(_ coordinate: Coordinate, attackedBy side: PieceColor, board: Board) -> Bool
}

public final class AttackCheckerImpl: AttackChecker {
    public init() {
    }

    public func isCoordinate(_ coordinate: Coordinate, attackedBy color: PieceColor, board: Board) -> Bool {
        // Pawns
        do {
            let advances: [(Int, Int)] = color == .white ? [(-1, -1), (1, -1)] : [(-1, 1), (1, 1)]
            for (dx, dy) in advances {
                if let newCoordinate = coordinate.advancedBy(dx, dy) {
                    if let other = board[newCoordinate], other.type == .pawn, other.color == color {
                        return true
                    }
                }
            }
        }

        // Knights
        do {
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
                    if let other = board[newCoordinate], other.color == color, other.type == .knight {
                        return true
                    }
                }
            }
        }

        // Bishops & Queens
        do {
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

                    if let other = board[newCoordinate] {
                        if other.color == color, other.type == .bishop || other.type == .queen {
                            return true
                        }

                        break
                    }
                } while true
            }
        }

        // Rooks & Queens
        do {
            let advances: [(Int, Int)] = [
                (-1, 0),
                (0, 1),
                (1, 0),
                (0, -1),
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

                    if let other = board[newCoordinate] {
                        if other.color == color, other.type == .rook || other.type == .queen {
                            return true
                        }

                        break
                    }
                } while true
            }
        }

        // King
        do {
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
                    if let other = board[newCoordinate], other.type == .king, other.color == color {
                        return true
                    }
                }
            }
        }

        return false
    }
}
