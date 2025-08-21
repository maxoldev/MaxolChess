//
//  MoveResultRepo.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 17.08.2025.
//

public struct MoveResult {
    public let moveId: MoveId?
    public let parentMoveId: MoveId?
    public let depth: Int
    public let gain: Double
    public let loss: Double
    public let staticCalculationValue: Double
    public var gainMaxPotential: Double
    public var lossMaxPotential: Double
}

actor MoveResultRepo {
    private var moveResults: [MoveId: MoveResult] = [:]

    func moveResultReceived(_ result: MoveResult) async {
        if let parentMoveId = result.parentMoveId, var parentMoveResult = moveResults[parentMoveId] {
            parentMoveResult.gainMaxPotential = max(result.gainMaxPotential, parentMoveResult.gainMaxPotential)
            parentMoveResult.lossMaxPotential = min(result.lossMaxPotential, parentMoveResult.lossMaxPotential)
        }
    }
}
