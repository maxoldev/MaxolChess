//
//  AttackCheckerTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 30.08.2025.
//

import Testing

@testable import MaxolChess

struct AttackCheckerTest {
    let attackChecker = AttackCheckerImpl()

    @Test func startPosition() async throws {
        for i in 0..<16 {
            #expect(attackChecker.isCoordinate(Coordinate(i), attackedBy: .black, board: Board.start) == false)
        }
        for i in 64 - 16..<64 {
            #expect(attackChecker.isCoordinate(Coordinate(i), attackedBy: .white, board: Board.start) == false)
        }

        for x in 0..<8 {
            #expect(attackChecker.isCoordinate(Coordinate(x, 2), attackedBy: .white, board: Board.start) == true)
        }
        for x in 0..<8 {
            #expect(attackChecker.isCoordinate(Coordinate(x, 5), attackedBy: .black, board: Board.start) == true)
        }
    }

    @Test func pawnAttacks() async throws {
        do {
            let board = try #require(Board(pieces: ("P", "e5")))

            let expectedPawnAttacksFromE5: Set<Coordinate> = ["d6", "f6"]

            for i in 0..<Const.boardSquareCount {
                let coord = Coordinate(i)
                #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedPawnAttacksFromE5.contains(coord))
            }
        }
        do {
            let board = try #require(Board(pieces: ("p", "e5")))

            let expectedPawnAttacksFromE5: Set<Coordinate> = ["d4", "f4"]

            for i in 0..<Const.boardSquareCount {
                let coord = Coordinate(i)
                #expect(attackChecker.isCoordinate(coord, attackedBy: .black, board: board) == expectedPawnAttacksFromE5.contains(coord))
            }
        }
    }

    @Test func knightAttacks() async throws {
        let board = try #require(Board(pieces: (Piece(.white, .knight), "e5")))

        let expectedAttackedCoordinates: Set<Coordinate> = ["c6", "d7", "f7", "g6", "g4", "f3", "d3", "c4"]

        for i in 0..<Const.boardSquareCount {
            let coord = Coordinate(i)
            #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedAttackedCoordinates.contains(coord))
        }
    }

    private let expectedBishopAttacksFromE5: Set<Coordinate> = [
        "d6", "c7", "b8", "f6", "g7", "h8", "f4", "g3", "h2", "d4", "c3", "b2", "a1",
    ]

    @Test func bishopAttacks() async throws {
        let board = try #require(Board(pieces: (Piece(.white, .bishop), "e5")))

        for i in 0..<Const.boardSquareCount {
            let coord = Coordinate(i)
            #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedBishopAttacksFromE5.contains(coord))
        }
    }

    private let expectedRookAttacksfromE5: Set<Coordinate> = [
        "d5", "c5", "b5", "a5", "e6", "e7", "e8", "f5", "g5", "h5", "e4", "e3", "e2", "e1",
    ]

    @Test func rookAttacks() async throws {
        let board = try #require(Board(pieces: (Piece(.white, .rook), "e5")))

        for i in 0..<Const.boardSquareCount {
            let coord = Coordinate(i)
            #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedRookAttacksfromE5.contains(coord))
        }
    }

    @Test func queenAttacks() async throws {
        let board = try #require(Board(pieces: (Piece(.white, .queen), "e5")))

        let expectedQueenAttacksFromE5 = expectedBishopAttacksFromE5.union(expectedRookAttacksfromE5)

        for i in 0..<Const.boardSquareCount {
            let coord = Coordinate(i)
            #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedQueenAttacksFromE5.contains(coord))
        }
    }

    @Test func kingAttacks() async throws {
        let board = try #require(Board(pieces: (Piece(.white, .king), "e5")))

        let expectedKingAttacksFromE5: Set<Coordinate> = ["d5", "d6", "e6", "f6", "f5", "f4", "e4", "d4"]

        for i in 0..<Const.boardSquareCount {
            let coord = Coordinate(i)
            #expect(attackChecker.isCoordinate(coord, attackedBy: .white, board: board) == expectedKingAttacksFromE5.contains(coord))
        }
    }
}
