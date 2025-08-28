//
//  ModelsInitialization.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import Testing

@testable import MaxolChess

struct ModelsInitialization {
    @Test func coordinate() async throws {
        #expect(Coordinate("a1").x == 0 && Coordinate("a1").y == 0)
        #expect(Coordinate("h8").x == 7 && Coordinate("h8").y == 7)

        #expect(Coordinate(0).x == 0 && Coordinate(0).y == 0)
        #expect(Coordinate(63).x == 7 && Coordinate(63).y == 7)

        let coord: Coordinate = "e5"
        #expect(coord.x == 4 && coord.y == 4)
    }

    @Test func fen() async throws {
        let fenBoard = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        let board = try #require(Board(fenBoardSubstring: fenBoard))
        var pos = try #require(Position(fen: "\(fenBoard) w KQkq - 0 1"))
        let expected: [Square] =
            "RNBQKBNRPPPPPPPP".map(Piece.init) + [Square](repeating: nil, count: 32) + "pppppppprnbqkbnr".map(Piece.init)

        for idx in 0..<expected.count {
            let coord = Coordinate(idx)
            #expect(board[coord] == expected[idx])
            #expect(pos.board[coord] == expected[idx])
            #expect(pos.sideToMove == .white)
        }

        #expect(Board(fenBoardSubstring: fenBoard)?.fenString == fenBoard)

        #expect(pos.castlingRights[.white]?.count == 2)
        #expect(pos.castlingRights[.white]?.contains(.kingSide) == true)
        #expect(pos.castlingRights[.white]?.contains(.queenSide) == true)
        #expect(pos.castlingRights[.black]?.contains(.kingSide) == true)
        #expect(pos.castlingRights[.black]?.contains(.queenSide) == true)
        #expect(pos.castlingRights[.black]?.count == 2)

        #expect(pos.halfMoveCountSinceLastCaptureOrPawnMove == 0)
        #expect(pos.fullMoveIndex == 1)

        #expect(try #require(Position(fen: "\(fenBoard) b KQkq - 0 1")).sideToMove == .black)

        #expect(try #require(Position(fen: "\(fenBoard) b KQkq - 10 11")).halfMoveCountSinceLastCaptureOrPawnMove == 10)
        #expect(try #require(Position(fen: "\(fenBoard) b KQkq - 10 11")).fullMoveIndex == 11)

        pos = try #require(Position(fen: "\(fenBoard) w - - 0 1"))
        #expect(pos.castlingRights[.white]?.count == 0)
        #expect(pos.castlingRights[.black]?.count == 0)
    }

    @Test func invalidFen() async throws {
        #expect(Board(fenBoardSubstring: "") == nil)
        #expect(Board(fenBoardSubstring: "a") == nil)
        #expect(Board(fenBoardSubstring: "r/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)
        #expect(Board(fenBoardSubstring: "pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)
        #expect(Board(fenBoardSubstring: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR/rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)

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
