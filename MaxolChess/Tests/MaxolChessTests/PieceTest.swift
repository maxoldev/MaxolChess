//
//  PieceTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 19.08.2025.
//

import Testing

@testable import MaxolChess

struct PieceTest {
    @Test func initialization() async throws {
        #expect(try #require(Piece(Character("P"))) == Piece(.white, .pawn))
        #expect(try #require(Piece(Character("N"))) == Piece(.white, .knight))
        #expect(try #require(Piece(Character("B"))) == Piece(.white, .bishop))
        #expect(try #require(Piece(Character("R"))) == Piece(.white, .rook))
        #expect(try #require(Piece(Character("Q"))) == Piece(.white, .queen))
        #expect(try #require(Piece(Character("K"))) == Piece(.white, .king))
        #expect(try #require(Piece(Character("♙"))) == Piece(.white, .pawn))
        #expect(try #require(Piece(Character("♘"))) == Piece(.white, .knight))
        #expect(try #require(Piece(Character("♗"))) == Piece(.white, .bishop))
        #expect(try #require(Piece(Character("♖"))) == Piece(.white, .rook))
        #expect(try #require(Piece(Character("♕"))) == Piece(.white, .queen))
        #expect(try #require(Piece(Character("♔"))) == Piece(.white, .king))
        #expect("P" == Piece(.white, .pawn))
        #expect("N" == Piece(.white, .knight))
        #expect("B" == Piece(.white, .bishop))
        #expect("R" == Piece(.white, .rook))
        #expect("Q" == Piece(.white, .queen))
        #expect("K" == Piece(.white, .king))
        #expect("♙" == Piece(.white, .pawn))
        #expect("♘" == Piece(.white, .knight))
        #expect("♗" == Piece(.white, .bishop))
        #expect("♖" == Piece(.white, .rook))
        #expect("♕" == Piece(.white, .queen))
        #expect("♔" == Piece(.white, .king))

        #expect(try #require(Piece(Character("p"))) == Piece(.black, .pawn))
        #expect(try #require(Piece(Character("n"))) == Piece(.black, .knight))
        #expect(try #require(Piece(Character("b"))) == Piece(.black, .bishop))
        #expect(try #require(Piece(Character("r"))) == Piece(.black, .rook))
        #expect(try #require(Piece(Character("q"))) == Piece(.black, .queen))
        #expect(try #require(Piece(Character("k"))) == Piece(.black, .king))
        #expect(try #require(Piece(Character("♟"))) == Piece(.black, .pawn))
        #expect(try #require(Piece(Character("♞"))) == Piece(.black, .knight))
        #expect(try #require(Piece(Character("♝"))) == Piece(.black, .bishop))
        #expect(try #require(Piece(Character("♜"))) == Piece(.black, .rook))
        #expect(try #require(Piece(Character("♛"))) == Piece(.black, .queen))
        #expect(try #require(Piece(Character("♚"))) == Piece(.black, .king))
        #expect("p" == Piece(.black, .pawn))
        #expect("n" == Piece(.black, .knight))
        #expect("b" == Piece(.black, .bishop))
        #expect("r" == Piece(.black, .rook))
        #expect("q" == Piece(.black, .queen))
        #expect("k" == Piece(.black, .king))
        #expect("♟" == Piece(.black, .pawn))
        #expect("♞" == Piece(.black, .knight))
        #expect("♝" == Piece(.black, .bishop))
        #expect("♜" == Piece(.black, .rook))
        #expect("♛" == Piece(.black, .queen))
        #expect("♚" == Piece(.black, .king))

        #expect(Piece(Character("a")) == nil)
    }

    @Test func defaultValue() async throws {
        #expect(PieceType.pawn.defaultValue == 1)
        #expect(PieceType.knight.defaultValue == 3)
        #expect(PieceType.bishop.defaultValue == 3)
        #expect(PieceType.rook.defaultValue == 5)
        #expect(PieceType.queen.defaultValue == 9)
        #expect(PieceType.king.defaultValue == 1000)
    }

    @Test func oppositeColor() async throws {
        #expect(PieceColor.white.opposite == .black)
        #expect(PieceColor.black.opposite == .white)
    }

    @Test func char() async throws {
        #expect(Piece(.white, .pawn).char(unicode: false) == "P")
        #expect(Piece(.white, .knight).char(unicode: false) == "N")
        #expect(Piece(.white, .bishop).char(unicode: false) == "B")
        #expect(Piece(.white, .rook).char(unicode: false) == "R")
        #expect(Piece(.white, .queen).char(unicode: false) == "Q")
        #expect(Piece(.white, .king).char(unicode: false) == "K")

        #expect(Piece(.black, .pawn).char(unicode: false) == "p")
        #expect(Piece(.black, .knight).char(unicode: false) == "n")
        #expect(Piece(.black, .bishop).char(unicode: false) == "b")
        #expect(Piece(.black, .rook).char(unicode: false) == "r")
        #expect(Piece(.black, .queen).char(unicode: false) == "q")
        #expect(Piece(.black, .king).char(unicode: false) == "k")
    }
}
