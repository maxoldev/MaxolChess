//
//  PositionCheckerTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 24.08.2025.
//

import Testing

@testable import MaxolChess

struct PositionCheckerTest {
    @Test func valid() async throws {
        #expect(PositionCheckerImpl().check(Position.start) == .valid)
    }

    @Test func invalid() async throws {
        #expect(
            PositionCheckerImpl().check(
                Position(
                    Board(
                        prettyPrinted: """
                              ┌───────────────┐
                            8  ♔ . ♛ . . . . .
                            7  . . . . . . . .
                            6  ♚ . ♕ . . . . .
                            5  . . . . . . . .
                            4  . . . . . . . .
                            3  . . . . . . . .
                            2  . . . . . . . .
                            1  . . . . . . . .
                              └───────────────┘
                               a b c d e f g h
                            """
                    )!, turn: .white
                )
            ) == .invalid2KingsInCheck
        )
    }
}
