//
//  PositionTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 18.08.2025.
//

import MaxolChess
import Testing

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

    @Test func multiline() async throws {
        #expect(
            try #require(
                Position(
                    multiline: """
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
                        w KQkq - 0 1
                        """
                )
            ) == Position.start
        )

        #expect(
            try #require(
                Position(
                    multiline: """


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
                        w KQkq - 0 1
                        """
                )
            ) == Position.start
        )
        
        #expect(
            try #require(
                Position(
                    multiline: """
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


                        w KQkq - 0 1
                        """
                )
            ) == Position.start
        )

        #expect(
            try #require(
                Position(
                    multiline: """
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
                        w KQkq - 0 1
                        """
                )
            ) == Position.start
        )
    }

    @Test func invalidMultiline() async throws {
        #expect(
            Position(
                multiline: """
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
            ) == nil
        )

        #expect(
            Position(
                multiline: """
                      ┌───────────────┐
                    8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
                    7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
                    6  . . . . . . . .
                    2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
                    1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
                      └───────────────┘
                       a b c d e f g h
                    w KQkq - 0 1
                    """
            ) == nil
        )
    }
}
