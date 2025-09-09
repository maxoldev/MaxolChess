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

Config.shared = Config.game

let opponentColor = PieceColor.white
let engine: Engine = EngineImpl(configuration: EngineConfiguration(maxDepth: 4), gameState: GameState(position: Position.start))
let legalMoveGenerator: LegalMoveGenerator = LegalMoveGeneratorImpl()

print("You are playing \(opponentColor)")

while true {
    print("Current position:", engine.getCurrentState().position)
    print("\nEnter your move: ", terminator: "")
    if let input = readLine() {
        guard input.count == 4 else {
            print("Ivalid move format. Use long algebraic notation e.g. e2e4")
            continue
        }

        let fromStr = String(input.prefix(2))
        let toStr = String(input.suffix(2))
        guard let from = Coordinate(fromStr) else {
            print("Invalid coordinate from \(fromStr)")
            continue
        }

        guard let to = Coordinate(toStr) else {
            print("Invalid coordinate to \(toStr)")
            continue
        }

        let pos = engine.getCurrentState().position
        guard let piece = pos.board[from], piece.color == opponentColor else {
            print("Invalid coordinate from \(from). No \(opponentColor) piece on this square")
            continue
        }

        let legalOpponentMoves = legalMoveGenerator.generateLegalMoves(engine.getCurrentState().position, parentMoveId: nil)

        guard
            let opponentMove = legalOpponentMoves.first(where: {
                ($0 as? RepositionMove)?.from == from && ($0 as? RepositionMove)?.to == to
                    || ($0 as? CaptureMove)?.from == from && ($0 as? CaptureMove)?.to == to
            })
        else {
            print("No legal move \(from)\(to) found")
            continue
        }
        print("Opponent's move: \(opponentMove)")
        engine.setMove(opponentMove)
        print("Position after opponent's move:", engine.getCurrentState().position)

        print("\nThinking...\n")
        let bestMove = await engine.calculateBestMove()
        print("BEST FOUND MOVE:", bestMove ?? "NO MOVE FOUND. GG")
        if let bestMove {
            engine.setMove(bestMove)
        }
    } else {
        print("exit")
        break
    }
}
