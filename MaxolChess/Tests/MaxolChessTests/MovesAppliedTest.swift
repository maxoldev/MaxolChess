//
//  MovesAppliedTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct MovesAppliedTest {
    @Test func reposition() async throws {
        let move = RepositionMove(parentMoveId: nil, piece: Piece(.white, .pawn), from: "e2", to: "e4")
        let newPos = Position(try #require(Board(pieces: (Piece(.white, .pawn), "e2"))), sideToMove: .white).applied(move: move)
        #expect(newPos.board.fenString == "8/8/8/8/4P3/8/8/8")
    }

    @Test func castlingRights() async throws {
        let pos = try #require(Position(fen: "R3K2R/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))
        #expect(pos.castlingRights[.white]?.count == 2)
        #expect(pos.castlingRights[.black]?.count == 2)

        let posAfterWhiteKingMove = try #require(Position(fen: "R3K2R/8/8/8/8/8/8/R3K2R w KQkq - 0 1")).applied(
            move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .king), from: "e1", to: "e2")
        )
        #expect(posAfterWhiteKingMove.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterWhiteKingMove.castlingRights[.black]?.count == 2)
        #expect(posAfterWhiteKingMove.fenString == "R3K2R/8/8/8/8/8/4K3/R6R b kq - 0 1")

        let posAfterBlackKingMove = try #require(Position(fen: "R3K2R/8/8/8/8/8/8/R3K2R b KQkq - 0 1")).applied(
            move: RepositionMove(parentMoveId: nil, piece: Piece(.black, .king), from: "e8", to: "e7")
        )
        #expect(posAfterBlackKingMove.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterBlackKingMove.castlingRights[.white]?.count == 2)
        #expect(posAfterBlackKingMove.fenString == "R6R/4K3/8/8/8/8/8/R3K2R w KQ - 0 1")

        let posAfterBothKingsMove = try #require(Position(fen: "R3K2R/8/8/8/8/8/8/R3K2R w KQkq - 0 1")).applied(
            move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .king), from: "e1", to: "e2")
        ).applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.black, .king), from: "e8", to: "e7"))
        #expect(posAfterBothKingsMove.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterBothKingsMove.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterBothKingsMove.fenString == "R6R/4K3/8/8/8/8/4K3/R6R w - - 0 1")
    }
}
