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
        #expect(try #require(Piece("P")) == Piece(.white, .pawn))
        #expect(try #require(Piece("N")) == Piece(.white, .knight))
        #expect(try #require(Piece("B")) == Piece(.white, .bishop))
        #expect(try #require(Piece("R")) == Piece(.white, .rook))
        #expect(try #require(Piece("Q")) == Piece(.white, .queen))
        #expect(try #require(Piece("K")) == Piece(.white, .king))
        #expect(try #require(Piece("♙")) == Piece(.white, .pawn))
        #expect(try #require(Piece("♘")) == Piece(.white, .knight))
        #expect(try #require(Piece("♗")) == Piece(.white, .bishop))
        #expect(try #require(Piece("♖")) == Piece(.white, .rook))
        #expect(try #require(Piece("♕")) == Piece(.white, .queen))
        #expect(try #require(Piece("♔")) == Piece(.white, .king))

        #expect(try #require(Piece("p")) == Piece(.black, .pawn))
        #expect(try #require(Piece("n")) == Piece(.black, .knight))
        #expect(try #require(Piece("b")) == Piece(.black, .bishop))
        #expect(try #require(Piece("r")) == Piece(.black, .rook))
        #expect(try #require(Piece("q")) == Piece(.black, .queen))
        #expect(try #require(Piece("k")) == Piece(.black, .king))
        #expect(try #require(Piece("♟")) == Piece(.black, .pawn))
        #expect(try #require(Piece("♞")) == Piece(.black, .knight))
        #expect(try #require(Piece("♝")) == Piece(.black, .bishop))
        #expect(try #require(Piece("♜")) == Piece(.black, .rook))
        #expect(try #require(Piece("♛")) == Piece(.black, .queen))
        #expect(try #require(Piece("♚")) == Piece(.black, .king))

        #expect((Piece("a")) == nil)
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
