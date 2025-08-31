//
//  PositionValidatorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 24.08.2025.
//

import Testing

import MaxolChess

struct PositionValidatorTest {
    @Test func valid() async throws {
        #expect(PositionValidatorImpl().validate(Position.start) == .valid)
    }

    @Test func invalid() async throws {
        #expect(
            PositionValidatorImpl().validate(
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
                    )!,
                    sideToMove: .white
                )
            ) == .invalid2KingsInCheck
        )
    }
}
