//
//  MoveResultRepo.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct MoveResult {
    public let moveId: MoveId
    public let parentMoveId: MoveId?
    public let depth: Int
    public let advantage: PieceValue
}

actor MoveResultRepo {
    private var moveResults: [MoveId: MoveResult] = [:]

    func bestMoveId(for side: PieceColor) -> MoveId? {
        if side == .white {
            moveResults.values.sorted { $0.advantage > $1.advantage }.first?.moveId
        } else {
            moveResults.values.sorted { $0.advantage < $1.advantage }.first?.moveId
        }
    }

    func moveResultReceived(_ result: MoveResult) async {
        moveResults[result.moveId] = result
//        if let parentMoveId = result.parentMoveId, var parentMoveResult = moveResults[parentMoveId] {
//            parentMoveResult.gainMaxPotential = max(result.gainMaxPotential, parentMoveResult.gainMaxPotential)
//            parentMoveResult.lossMaxPotential = min(result.lossMaxPotential, parentMoveResult.lossMaxPotential)
//        }
    }

    func clear() {
        moveResults.removeAll()
    }
}
