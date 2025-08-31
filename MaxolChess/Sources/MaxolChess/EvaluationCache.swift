//
//  EvaluationCache.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 31.08.2025.
//

public protocol EvaluationCache: Sendable {
    func get(_ position: String) async -> PositionEvaluation?
    func set(_ evaluation: PositionEvaluation, for position: String) async
    func itemCount() async -> Int
}

public actor EvaluationCacheImpl: EvaluationCache {
    public init() {
    }

    private var dict = [String: PositionEvaluation]()

    public func get(_ position: String) async -> PositionEvaluation? {
        dict[position]
    }

    public func set(_ evaluation: PositionEvaluation, for position: String) async {
        dict[position] = evaluation
    }

    public func itemCount() async -> Int {
        dict.count
    }
}
