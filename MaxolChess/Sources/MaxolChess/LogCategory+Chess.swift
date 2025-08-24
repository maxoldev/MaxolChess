//
//  LogCategory+Chess.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 22.08.2025.
//

extension LogCategory {
    nonisolated(unsafe) static let engine = LogCategory(name: "Engine", prefix: "🤖")
    nonisolated(unsafe) static let evaluator = LogCategory(name: "Evaluator", prefix: "⚖️")
    nonisolated(unsafe) static let calculator = LogCategory(name: "Calculator", prefix: "🧮")
    nonisolated(unsafe) static let moveGenerator = LogCategory(name: "MoveGen", prefix: "🔀")
}
