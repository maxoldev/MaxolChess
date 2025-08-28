//
//  MoveResultRepo.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct MoveResult {
    public let side: PieceColor
//    public let moveId: MoveId
//    public let parentMoveId: MoveId?
    public let move: any Move
    public let depth: Int
    public let gain: PieceValue
    public let isEnemyKingChecked: Bool
    public let isEnemyKingCheckmated: Bool
    public let isEnemyKingStalemated: Bool
    public let isDraw: Bool
//    public var maxPotentialLoss: PieceValue
}

actor MoveResultRepo {
    enum MoveResultRepo: Error {
        case moveResultNotFound
    }

    private var moveResults = [MoveId: MoveResult]()
    private var zeroDepthMoves = [any Move]()

    func bestMove() async -> Move? {
        let zeroDepthMoveResults = zeroDepthMoves.map { moveResults[$0.id]! }
        let checkmates = zeroDepthMoveResults.filter { $0.isEnemyKingCheckmated }
        if let firstCheckmate = checkmates.first?.move {
            return firstCheckmate
        }
        
        let move = zeroDepthMoves.sorted { moveResults[$0.id]!.gain > moveResults[$1.id]!.gain }.first
        logConsoleMarked(moveResults[move!.id])
        return move
    }

    func add(move: any Move) async {
        zeroDepthMoves.append(move)
    }

    func add(moveResult: MoveResult) async {
        moveResults[moveResult.move.id] = moveResult
    }
    
    func clear() {
        zeroDepthMoves.removeAll()
        moveResults.removeAll()
    }
}
