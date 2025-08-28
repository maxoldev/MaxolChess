//
//  Move.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 16.08.2025.
//

import Foundation

public typealias MoveId = UUID

public protocol Move: Sendable {
    var id: MoveId { get }
    var parentMoveId: UUID? { get }
    var piece: Piece { get }
}

public struct RepositionMove: Move {
    public let id = MoveId()
    public let parentMoveId: MoveId?
    public let piece: Piece
    public let from: Coordinate
    public let to: Coordinate

    public func isEqual(to other: RepositionMove) -> Bool {
        piece == other.piece && from == other.from && to == other.to
    }
}

extension RepositionMove: CustomStringConvertible {
    public var description: String {
        "\(piece)\(from)-\(to)\(Config.logMoveId ? " \(id.shortString)\(parentMoveId.map { "<-"+$0.shortString } ?? "")" : "")"
    }
}

public struct CaptureMove: Move {
    public let id = UUID()
    public let parentMoveId: UUID?
    public let piece: Piece
    public let from: Coordinate
    public let to: Coordinate
    public let captured: Piece
}

extension CaptureMove: CustomStringConvertible {
    public var description: String {
        "\(piece)x\(captured)\(from)-\(to)\(Config.logMoveId ? " \(id.shortString)\(parentMoveId.map { "<-"+$0.shortString } ?? "")" : "")"
    }
}

public struct CastlingMove: Move {
    public let id = UUID()
    public let parentMoveId: UUID?
    public let piece: Piece
    public let side: CastlingSide
}

extension CastlingMove: CustomStringConvertible {
    public var description: String {
        "\(side)\(Config.logMoveId ? " \(id.shortString)\(parentMoveId.map { "←"+$0.shortString } ?? "")" : "")"
    }
}

public struct PromotionMove: Move {
    public let id = UUID()
    public let parentMoveId: UUID?
    public let piece: Piece
    public let from: Coordinate
    public let to: Coordinate
    public let promotedPiece: Piece
    public let capture: Piece?
}

extension PromotionMove: CustomStringConvertible {
    public var description: String {
        "\(piece)\(capture.map { "x"+$0.description } ?? "")→\(promotedPiece) \(from)-\(to)\(Config.logMoveId ? " \(id.shortString)\(parentMoveId.map { "<-"+$0.shortString } ?? "")" : "")"
    }
}
