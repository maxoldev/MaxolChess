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
        let posAfterMove = Position.start.applied(move: RepositionMove(parentMoveId: nil, piece: "P", from: "e2", to: "e3"))
        #expect(posAfterMove.fenString == "rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR b KQkq - 0 1")
    }

    @Test func castlingRights() async throws {
        let pos = try #require(Position(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))
        #expect(pos.castlingRights[.white]?.count == 2)
        #expect(pos.castlingRights[.black]?.count == 2)

        let posAfterWhiteKingMove = pos.applied(move: RepositionMove(parentMoveId: nil, piece: "K", from: "e1", to: "e2"))
        #expect(posAfterWhiteKingMove.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterWhiteKingMove.castlingRights[.black]?.count == 2)
        #expect(posAfterWhiteKingMove.fenString == "r3k2r/8/8/8/8/8/4K3/R6R b kq - 1 1")

        let posAfterBlackKingMove = pos.opposite.applied(move: RepositionMove(parentMoveId: nil, piece: "k", from: "e8", to: "e7"))
        #expect(posAfterBlackKingMove.castlingRights[.white]?.count == 2)
        #expect(posAfterBlackKingMove.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterBlackKingMove.fenString == "r6r/4k3/8/8/8/8/8/R3K2R w KQ - 1 2")

        let posAfterBothKingsMove = pos.applied(move: RepositionMove(parentMoveId: nil, piece: "K", from: "e1", to: "e2"))
            .applied(move: RepositionMove(parentMoveId: nil, piece: "k", from: "e8", to: "e7"))
        #expect(posAfterBothKingsMove.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterBothKingsMove.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterBothKingsMove.fenString == "r6r/4k3/8/8/8/8/4K3/R6R w - - 2 2")
    }

    @Test func castling() async throws {
        let pos = try #require(Position(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))

        var posAfterCastling = pos.applied(move: CastlingMove(parentMoveId: nil, side: .kingSide))
        #expect(posAfterCastling.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterCastling.fenString == "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 1 1")

        posAfterCastling = pos.applied(move: CastlingMove(parentMoveId: nil, side: .queenSide))
        #expect(posAfterCastling.castlingRights[.white]?.isEmpty == true)
        #expect(posAfterCastling.fenString == "r3k2r/8/8/8/8/8/8/2KR3R b kq - 1 1")

        posAfterCastling = pos.opposite.applied(move: CastlingMove(parentMoveId: nil, side: .kingSide))
        #expect(posAfterCastling.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterCastling.fenString == "r4rk1/8/8/8/8/8/8/R3K2R w KQ - 1 2")

        posAfterCastling = pos.opposite.applied(move: CastlingMove(parentMoveId: nil, side: .queenSide))
        #expect(posAfterCastling.castlingRights[.black]?.isEmpty == true)
        #expect(posAfterCastling.fenString == "2kr3r/8/8/8/8/8/8/R3K2R w KQ - 1 2")
    }
}
