//
//  Decider.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct BestMove: Sendable {
    public let move: Move
    public let moveResult: MoveResult
}

extension BestMove: CustomStringConvertible {
    public var description: String {
        "\(move) (\(moveResult))"
    }
}

public struct MoveResult: Sendable {
    public let side: PieceColor
//    public let moveId: MoveId
//    public let parentMoveId: MoveId?
    public let move: any Move
    public let capturedValue: PieceValue
    public let repositionDelta: PieceValue
    public let isEnemyKingChecked: Bool
    public let isEnemyKingCheckmated: Bool
    public let isEnemyKingStalemated: Bool
    public let isDraw: Bool
//    public var maxPotentialLoss: PieceValue
    public let depth: Int
}

extension MoveResult: CustomStringConvertible {
    public var description: String {
        let state = isEnemyKingCheckmated ? "#Checkmate" : isEnemyKingStalemated ? "Stalemate" : isDraw ? "Draw" : isEnemyKingChecked ? "+Check" : ""
        return "\(side) \(move.id.shortString) d=\(depth) cap=\(capturedValue) repos=\(repositionDelta) \(state)"
    }
}

public protocol Decider: Sendable {
    func bestMove() async -> BestMove?
    func set(zeroDepthMoves: [any Move]) async
    func add(moveResults: [MoveResult]) async
    func clear() async
    func itemCount() async -> Int
}

public actor DeciderImpl: Decider {
//    public enum MovePicker: Error {
//        case moveResultNotFound
//    }
    private var moveResults = [MoveId: MoveResult]()
    private var zeroDepthMoves = [any Move]()

    public init() {
    }
    
    public func bestMove() async -> BestMove? {
        let zeroDepthMoveResults = zeroDepthMoves.map { moveResults[$0.id]! }
        let checkmates = zeroDepthMoveResults.filter { $0.isEnemyKingCheckmated }
        if let firstCheckmate = checkmates.first?.move {
            return BestMove(move: firstCheckmate, moveResult: moveResults[firstCheckmate.id]!)
        }
        
        guard let move = zeroDepthMoves.sorted(by: {
            let firstMoveRes = moveResults[$0.id]!
            let secondMoveRes = moveResults[$1.id]!
            return firstMoveRes.capturedValue + firstMoveRes.repositionDelta > secondMoveRes.capturedValue + secondMoveRes.repositionDelta
        }).first else {
            return nil
        }

        return BestMove(move: move, moveResult: moveResults[move.id]!)
    }

    public func set(zeroDepthMoves: [any Move]) async {
        self.zeroDepthMoves = zeroDepthMoves
    }

    public func add(moveResults: [MoveResult]) async {
        moveResults.forEach {
            self.moveResults[$0.move.id] = $0
        }
    }
    
    public func clear() async {
        zeroDepthMoves.removeAll()
        moveResults.removeAll()
    }

    public func itemCount() async -> Int {
        moveResults.count
    }
}
