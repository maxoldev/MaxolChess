//
//  main.swift
//  MaxolChessConsole
//
//  Created by Maksim Solovev on 17.08.2025.
//

import Foundation
import MaxolChess
@_exported import MaxolLog

/// Chess game implementation

print("id name MaxolChess 1")
print("id author Maksim Solovev")
print("uciok")

print("readyok")

print(Position.start)
print(Position(fen: "r3k2r/ppp2ppp/8/3P4/6b1/bP1B4/PqP3PP/RK5R w kq - 1 17")!.prettyPrinted(unicode: false))
print(Position.start)

var p = Position.start
p.modify { board in
    board = Board()

    board["d5"] = Piece(.black, .pawn)
    board["f6"] = Piece(.black, .pawn)
    board["c7"] = Piece(.black, .bishop)
    board["d7"] = Piece(.black, .knight)
    board["e7"] = Piece(.black, .rook)
    board["h5"] = Piece(.black, .queen)
    board["f3"] = Piece(.black, .king)

    board["e5"] = Piece(.white, .king)
    print(board)
}
print(p.board)

let possibleMoveGen = PossibleMoveGeneratorImpl()
print(possibleMoveGen.generateAllMoves(p, parentMoveId: nil))

let staticValueCalc = ValueCalculatorImpl()
print(staticValueCalc.calculate(p))

let semaphore = DispatchSemaphore(value: 0)

Task {
    let pos = Position(fen: "1KR4R/qPP5/5P2/4Q1P1/1p2p2P/2pp4/3n1kp1/r7 b KQ - 0 1")!
    let posEval = PositionEvaluatorImpl()
    print(posEval.evaluate(pos))

    let engine = EngineImpl(gameState: GameState(ourSide: .black, position: pos))
    let move = await engine.calculateOurBestMove()
    print(move ?? "None")
    semaphore.signal()
}

semaphore.wait()
