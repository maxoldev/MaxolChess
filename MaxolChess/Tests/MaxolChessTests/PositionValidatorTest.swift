//
//  PositionValidatorTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 24.08.2025.
//

import MaxolChess
import Testing

struct PositionValidatorTest {
    @Test func start() async throws {
        #expect(PositionValidatorImpl().validate(Position.start) == .valid)
    }

    @Test func oneKingInCheck() async throws {
        #expect(
            PositionValidatorImpl().validate(
                Position(
                    Board(
                        multiline: """
                              ┌───────────────┐
                            8  K . Q . . . . .
                            7  . . . . . . . .
                            6  k . . . . . . .
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
            ) == .valid
        )
    }

    @Test func invalid() async throws {
        #expect(
            PositionValidatorImpl().validate(
                Position(
                    Board(
                        multiline: """
                              ┌───────────────┐
                            8  K . Q . . . . .
                            7  . . . . . . . .
                            6  k . q . . . . .
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
