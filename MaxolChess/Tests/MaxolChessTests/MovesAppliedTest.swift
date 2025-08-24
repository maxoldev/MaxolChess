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
        var pos = Position(Board(pieces: (Piece(.white, .pawn), "e2")), turn: .white)
        var newPos = pos.applied(move: move)
        #expect(newPos.board.fenString == "8/8/8/8/4P3/8/8/8")

        pos = try #require(Position(fen: "R3K2R/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))
        #expect(pos.castlingRights[.white]?.count == 2)
        #expect(pos.castlingRights[.black]?.count == 2)

        newPos = pos.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .king), from: "e1", to: "e2"))
        #expect(newPos.board.fenString == "R3K2R/8/8/8/8/8/4K3/R6R")
        #expect(newPos.castlingRights[.white]?.isEmpty == true)
        #expect(newPos.castlingRights[.black]?.count == 2)
        #expect(newPos.fenString == "R3K2R/8/8/8/8/8/4K3/R6R w kq - 0 1")

        newPos = pos.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.black, .king), from: "e8", to: "e7"))
        #expect(newPos.board.fenString == "R6R/4K3/8/8/8/8/8/R3K2R")
        #expect(newPos.castlingRights[.black]?.isEmpty == true)
        #expect(newPos.castlingRights[.white]?.count == 2)
        #expect(newPos.fenString == "R6R/4K3/8/8/8/8/8/R3K2R w KQ - 0 1")

        newPos = pos.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.black, .king), from: "e8", to: "e7"))
        newPos = newPos.applied(move: RepositionMove(parentMoveId: nil, piece: Piece(.white, .king), from: "e1", to: "e2"))
        #expect(newPos.board.fenString == "R6R/4K3/8/8/8/8/4K3/R6R")
        #expect(newPos.castlingRights[.black]?.isEmpty == true)
        #expect(newPos.castlingRights[.white]?.isEmpty == true)
        #expect(newPos.fenString == "R6R/4K3/8/8/8/8/4K3/R6R w - - 0 1")
    }
}
