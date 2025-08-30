//
//  PositionTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct PositionTest {
    @Test func initialization() async throws {
        let fenBoardSubstring = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        var pos = try #require(Position(fen: "\(fenBoardSubstring) w KQkq - 0 1"))
        let startPos = Position.start

        let expected: [Square] =
            "RNBQKBNRPPPPPPPP".map(Piece.init) + [Square](repeating: nil, count: 32) + "pppppppprnbqkbnr".map(Piece.init)

        for idx in 0..<expected.count {
            let coord = Coordinate(idx)
            #expect(pos.board[coord] == expected[idx])
            #expect(startPos.board[coord] == expected[idx])
            #expect(pos.sideToMove == .white)
        }

        #expect(pos.castlingRights[.white]?.count == 2)
        #expect(pos.castlingRights[.white]?.contains(.kingSide) == true)
        #expect(pos.castlingRights[.white]?.contains(.queenSide) == true)
        #expect(pos.castlingRights[.black]?.contains(.kingSide) == true)
        #expect(pos.castlingRights[.black]?.contains(.queenSide) == true)
        #expect(pos.castlingRights[.black]?.count == 2)

        #expect(pos.halfMoveCountSinceLastCaptureOrPawnMove == 0)
        #expect(pos.fullMoveIndex == 1)

        #expect(try #require(Position(fen: "\(fenBoardSubstring) b KQkq - 0 1")).sideToMove == .black)

        #expect(try #require(Position(fen: "\(fenBoardSubstring) b KQkq - 10 11")).halfMoveCountSinceLastCaptureOrPawnMove == 10)
        #expect(try #require(Position(fen: "\(fenBoardSubstring) b KQkq - 10 11")).fullMoveIndex == 11)

        pos = try #require(Position(fen: "\(fenBoardSubstring) w - - 0 1"))
        #expect(pos.castlingRights[.white]?.count == 0)
        #expect(pos.castlingRights[.black]?.count == 0)
    }

    @Test func invalidFen() async throws {
        #expect(Position(fen: "") == nil)
        #expect(Position(fen: "a") == nil)
        #expect(Position(fen: "a KQkq - 0 1") == nil)
        #expect(Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR KQkq - 0 1") == nil)
        #expect(Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - 0 1") == nil)
        #expect(Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq 0 1") == nil)
        #expect(Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0") == nil)
        #expect(Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 1") == nil)
    }
}
