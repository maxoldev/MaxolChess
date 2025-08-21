//
//  PossibleMovesTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct PossibleMovesTest {
    let moveGen = PossibleMoveGeneratorImpl()

    @Test func pawnMovesOnEmptyBoard() async throws {
        var pos = Position(Board(pieces: (Piece(.white, .pawn), "e2")), turn: .white)
        var moves = moveGen.generateAllMoves(pos, parentMoveId: nil)
        #expect(moves.count == 2)
        #expect((moves[0] as? RepositionMove)?.from == "e2")
        #expect((moves[0] as? RepositionMove)?.to == "e3")
        #expect((moves[1] as? RepositionMove)?.from == "e2")
        #expect((moves[1] as? RepositionMove)?.to == "e4")

        pos = Position(Board(pieces: (Piece(.black, .pawn), "e7")), turn: .black)
        moves = moveGen.generateAllMoves(pos, parentMoveId: nil)
        #expect(moves.count == 2)
        #expect((moves[0] as? RepositionMove)?.from == "e7")
        #expect((moves[0] as? RepositionMove)?.to == "e6")
        #expect((moves[1] as? RepositionMove)?.from == "e7")
        #expect((moves[1] as? RepositionMove)?.to == "e5")

        pos = Position(Board(pieces: (Piece(.white, .pawn), "e3")), turn: .white)
        moves = moveGen.generateAllMoves(pos, parentMoveId: nil)
        #expect(moves.count == 1)
        #expect((moves[0] as? RepositionMove)?.from == "e3")
        #expect((moves[0] as? RepositionMove)?.to == "e4")

        pos = Position(Board(pieces: (Piece(.white, .pawn), "e4")), turn: .white)
        moves = moveGen.generateAllMoves(pos, parentMoveId: nil)
        #expect(moves.count == 1)
        #expect((moves[0] as? RepositionMove)?.from == "e4")
        #expect((moves[0] as? RepositionMove)?.to == "e5")
    }

    @Test func knightMovesOnEmptyBoard() async throws {
        let pos = Position(Board(pieces: (Piece(.white, .knight), "e5")), turn: .white)
        let moves = moveGen.generateAllMoves(pos, parentMoveId: nil)

        #expect(moves.count == 8)
        for (idx, expectedTo) in ["c6", "d7", "f7", "g6", "g4", "f3", "d3", "c4"].enumerated() {
            #expect((moves[idx] as? RepositionMove)?.from == "e5")
            #expect((moves[idx] as? RepositionMove)?.to == Coordinate(expectedTo))
        }
    }

    private var expectedBishopMovesFromE5: [String] {
        ["d6", "c7", "b8", "f6", "g7", "h8", "f4", "g3", "h2", "d4", "c3", "b2", "a1"]
    }

    @Test func bishopMovesOnEmptyBoard() async throws {
        let pos = Position(Board(pieces: (Piece(.white, .bishop), "e5")), turn: .white)
        let moves = moveGen.generateAllMoves(pos, parentMoveId: nil)

        #expect(moves.count == 13)
        for (idx, expectedTo) in expectedBishopMovesFromE5.enumerated() {
            #expect((moves[idx] as? RepositionMove)?.from == "e5")
            #expect((moves[idx] as? RepositionMove)?.to == Coordinate(expectedTo))
        }
    }

    private var expectedRookMovesFromE5: [String] {
        ["d5", "c5", "b5", "a5", "e6", "e7", "e8", "f5", "g5", "h5", "e4", "e3", "e2", "e1"]
    }

    @Test func rookMovesOnEmptyBoard() async throws {
        let pos = Position(Board(pieces: (Piece(.white, .rook), "e5")), turn: .white)
        let moves = moveGen.generateAllMoves(pos, parentMoveId: nil)

        #expect(moves.count == 14)
        for (idx, expectedTo) in expectedRookMovesFromE5.enumerated() {
            #expect((moves[idx] as? RepositionMove)?.from == "e5")
            #expect((moves[idx] as? RepositionMove)?.to == Coordinate(expectedTo))
        }
    }

    @Test func queenMovesOnEmptyBoard() async throws {
        let pos = Position(Board(pieces: (Piece(.white, .queen), "e5")), turn: .white)
        let moves = moveGen.generateAllMoves(pos, parentMoveId: nil)

        #expect(moves.count == 27)
        for (idx, expectedTo) in (expectedRookMovesFromE5 + expectedBishopMovesFromE5).enumerated() {
            #expect((moves[idx] as? RepositionMove)?.from == "e5")
            #expect((moves[idx] as? RepositionMove)?.to == Coordinate(expectedTo))
        }
    }

    @Test func kingMovesOnEmptyBoard() async throws {
        let pos = Position(Board(pieces: (Piece(.white, .king), "e5")), turn: .white)
        let moves = moveGen.generateAllMoves(pos, parentMoveId: nil)

        #expect(moves.count == 8)
        for (idx, expectedTo) in ["d5", "d6", "e6", "f6", "f5", "f4", "e4", "d4"].enumerated() {
            #expect((moves[idx] as? RepositionMove)?.from == "e5")
            #expect((moves[idx] as? RepositionMove)?.to == Coordinate(expectedTo))
        }
    }
}
