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
            sideToMove: .black
        )
        let moves = legalMoveGen.generateLegalMoves(pos, parentMoveId: nil)
        #expect(moves.count == 1)
        let move = try #require(moves[0] as? RepositionMove)
        #expect(move.from == "f6" && move.to == "g6")
    }

    @Test func movesFromStartPosition() async throws {
        let legalMoves = legalMoveGen.generateLegalMoves(Position.start, parentMoveId: nil)
        let repositionMoves = try #require(legalMoves as? [RepositionMove])

        let expectedMoves = [
            RepositionMove(parentMoveId: nil, piece: "N", from: "b1", to: "a3"),
            RepositionMove(parentMoveId: nil, piece: "N", from: "b1", to: "c3"),
            RepositionMove(parentMoveId: nil, piece: "N", from: "g1", to: "f3"),
            RepositionMove(parentMoveId: nil, piece: "N", from: "g1", to: "h3"),

            RepositionMove(parentMoveId: nil, piece: "P", from: "a2", to: "a3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "a2", to: "a4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "b2", to: "b3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "b2", to: "b4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "c2", to: "c3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "c2", to: "c4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "d2", to: "d3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "d2", to: "d4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "e2", to: "e3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "e2", to: "e4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "f2", to: "f3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "f2", to: "f4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "g2", to: "g3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "g2", to: "g4"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "h2", to: "h3"),
            RepositionMove(parentMoveId: nil, piece: "P", from: "h2", to: "h4"),
        ]

        #expect(repositionMoves.count == expectedMoves.count)
        for move in expectedMoves {
            #expect(repositionMoves.firstIndex(where: { $0.from == move.from && $0.to == move.to }) != nil)
        }
    }
}
