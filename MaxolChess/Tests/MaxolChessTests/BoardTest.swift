//
//  BoardTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import Testing

@testable import MaxolChess

struct BoardTest {
    @Test func initialization() async throws {
        let fenBoardSubstring = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        let board = try #require(Board(fenBoardSubstring: fenBoardSubstring))
        let startBoard = Board.start

        #expect(board == startBoard)

        let expected: [Square] =
            "RNBQKBNRPPPPPPPP".map(Piece.init) + [Square](repeating: nil, count: 32) + "pppppppprnbqkbnr".map(Piece.init)

        for idx in 0..<expected.count {
            let coord = Coordinate(idx)
            #expect(board[coord] == expected[idx])
            #expect(startBoard[coord] == expected[idx])
        }

        #expect(Board(fenBoardSubstring: fenBoardSubstring)?.fenString == fenBoardSubstring)

        #expect(try #require(Board(pieces: (Piece(.white, .pawn), "a1")))[0] == Piece(.white, .pawn))
    }

    @Test func invalidFen() async throws {
        #expect(Board(fenBoardSubstring: "") == nil)
        #expect(Board(fenBoardSubstring: "a") == nil)
        #expect(Board(fenBoardSubstring: "r/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)
        #expect(Board(fenBoardSubstring: "pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)
        #expect(Board(fenBoardSubstring: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR/rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") == nil)
    }

    @Test func prettyPrinted() async throws {
        #expect(
            try #require(
                Board(
                    prettyPrinted: """
                          ┌───────────────┐
                        8  r n b q k b n r
                        7  p p p p p p p p
                        6  . . . . . . . .
                        5  . . . . . . . .
                        4  . . . . . . . .
                        3  . . . . . . . .
                        2  P P P P P P P P
                        1  R N B Q K B N R
                          └───────────────┘
                           a b c d e f g h
                        """
                )
            ) == Board.start
        )

        #expect(
            try #require(
                Board(
                    prettyPrinted: """
                          ┌───────────────┐
                        8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
                        7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ 
                        6  . . . . . . . . 
                        5  . . . . . . . . 
                        4  . . . . . . . . 
                        3  . . . . . . . . 
                        2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ 
                        1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
                          └───────────────┘
                           a b c d e f g h
                        """
                )
            ) == Board.start
        )

        #expect(
            Board(
                prettyPrinted: """
                      ┌───────────────┐
                    8  . ♔ ♖ . . . . ♖
                    7  ♛ ♙ ♙ . . . . .
                    6  . . . . . ♙ . .
                    5  . . . . ♕ . ♙ .
                    4  . ♟ . . ♟ . . ♙
                    3  . . ♟ ♟ . . . .
                    2  . . . ♞ . ♚ ♟ .
                    1  ♜ . . . . . . .
                      └───────────────┘
                       a b c d e f g h
                    """
            ) == Board(fenBoardSubstring: "1KR4R/qPP5/5P2/4Q1P1/1p2p2P/2pp4/3n1kp1/r7")
        )

        #expect(
            Board(
                prettyPrinted: """
                      ┌───────────────┐
                    8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
                    7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ 
                    6  . . . . . . . . 
                    2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ 
                    1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
                      └───────────────┘
                       a b c d e f g h
                    """
            ) == nil
        )

        #expect(
            Board(
                prettyPrinted: """
                      ───────────────┐
                    8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
                    7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ 
                    6  . . . . . . . . 
                    5  . . . . . . . . 
                    4  . . . . . . . . 
                    3  . . . . . . . . 
                    2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ 
                    1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
                      └───────────────┘
                       a b c d e f g h
                    """
            ) == nil
        )

        #expect(
            Board(
                prettyPrinted: """
                      ┌───────────────┐
                    8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
                    7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ 
                    6  . . . . . . . . 
                    5  . . . . . . . . 
                    4  . . . . . . . . 
                    3  . . . . . . . . 
                    2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ 
                    1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
                      └───────────────
                       a b c d e f g h
                    """
            ) == nil
        )
    }
}
