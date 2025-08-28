//
//  BoardTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import Testing

@testable import MaxolChess

/*
 Pretty printed chess boards
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
 */

struct BoardTest {
    @Test func pretty() async throws {
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
