//
//  CoordinateTest.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 30.08.2025.
//

import Testing

@testable import MaxolChess

struct CoordinateTest {
    @Test func test() async throws {
        #expect(Coordinate(0, 0).x == 0)
        #expect(Coordinate(0, 0).y == 0)
        #expect(Coordinate(0).x == 0)
        #expect(Coordinate(0).y == 0)
        #expect(Coordinate("a1").x == 0)
        #expect(Coordinate("a1").y == 0)
        #expect(Coordinate(7, 7).x == 7)
        #expect(Coordinate(7, 7).y == 7)
        #expect(Coordinate(63).x == 7)
        #expect(Coordinate(63).y == 7)
        #expect(Coordinate("h8").x == 7)
        #expect(Coordinate("h8").y == 7)

        let coord: Coordinate = "e5"
        #expect(coord.x == 4 && coord.y == 4)

        #expect(Coordinate("a1") == Coordinate(0))
    }

    @Test func leftmost() async throws {
        #expect(Coordinate("e1").leftmost == "a1")
        #expect(Coordinate("e8").leftmost == "a8")
    }

    @Test func rightmost() async throws {
        #expect(Coordinate("e1").rightmost == "h1")
        #expect(Coordinate("e8").rightmost == "h8")
    }

    @Test func valid() async throws {
        #expect(Coordinate("a1").isValid)
        #expect(Coordinate("h8").isValid)

        for x in 0..<Const.boardSize {
            for y in 0..<Const.boardSize {
                #expect(Coordinate(x, y).isValid)
            }
        }
    }

    @Test func invalid() async throws {
        #expect(Coordinate(String("a9")) == nil)
        #expect(Coordinate(String("aa")) == nil)
        #expect(Coordinate(String("11")) == nil)
        #expect(Coordinate(String("djkakjsdajk")) == nil)

        #expect(Coordinate(-1, 0).isValid == false)
        #expect(Coordinate(0, -1).isValid == false)
        #expect(Coordinate(Const.boardSize, 0).isValid == false)
        #expect(Coordinate(0, Const.boardSize).isValid == false)
    }
}
