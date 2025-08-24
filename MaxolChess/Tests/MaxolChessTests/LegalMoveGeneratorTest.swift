//
//  LegalMoveGeneratorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import Testing

@testable import MaxolChess

struct LegalMoveGeneratorTest {
    let legalMoveGen = LegalMoveGeneratorImpl()

    @Test func legalMoves() async throws {
        let pos = Position(
            Board(
                prettyPrinted: """
                      ┌───────────────┐
                    8  . . . . . . . .
                    7  . . . . . ♟ . .
                    6  . . . . . ♚ . .
                    5  . . . . ♕ . . .
                    4  . . . ♗ . . . .
                    3  . . ♔ . . . . .
                    2  . . . . . . . .
                    1  . . . . . . . .
                      └───────────────┘
                       a b c d e f g h
                    """
            )!,
            turn: .black
        )
        let moves = legalMoveGen.generateLegalMoves(pos, parentMoveId: nil)
        print(moves)
        #expect(moves.count == 1)
        let move = try #require(moves[0] as? RepositionMove)
        #expect(move.from == "f6" && move.to == "g6")
    }

    @Test func movesFromStartPosition() async throws {
        let pos = Position.start
        let legalMoves = legalMoveGen.generateLegalMoves(pos, parentMoveId: nil)
        let repositionMoves = try #require(legalMoves as? [RepositionMove])

        let expectedMoves = [
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .knight), from: "b1", to: "a3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .knight), from: "b1", to: "c3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .knight), from: "g1", to: "f3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .knight), from: "g1", to: "h3"),

            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "a2", to: "a3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "a2", to: "a4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "b2", to: "b3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "b2", to: "b4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "c2", to: "c3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "c2", to: "c4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "d2", to: "d3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "d2", to: "d4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "f2", to: "f3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "f2", to: "f4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "g2", to: "g3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "g2", to: "g4"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "h2", to: "h3"),
            RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "h2", to: "h4"),
        ]

        #expect(repositionMoves.count == expectedMoves.count)
        for move in expectedMoves {
            #expect(repositionMoves.firstIndex(where: { $0.from == move.from && $0.to == move.to }) != nil)
        }
    }
}
