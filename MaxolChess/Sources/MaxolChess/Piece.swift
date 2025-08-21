//
//  Piece.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 15.08.2025.
//

public enum PieceType: String {
    case king = "K"
    case queen = "Q"
    case rook = "R"
    case bishop = "B"
    case knight = "N"
    case pawn = "P"

    public var defaultValue: Double {
        switch self {
        case .king: return 1000
        case .queen: return 9
        case .rook: return 5
        case .bishop: return 3
        case .knight: return 3
        case .pawn: return 1
        }
    }
}

public enum PieceColor: String {
    case white = "w"
    case black = "b"

    public var opposite: PieceColor {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }
}

extension PieceColor: CustomStringConvertible {
    public var description: String {
        self == .white ? "white" : "black"
    }
}

public struct Piece: Equatable {
    public let color: PieceColor
    public let type: PieceType

    public init(_ color: PieceColor, _ type: PieceType) {
        self.color = color
        self.type = type
    }
}

extension Piece {
    public init?(_ char: Character) {
        if let type = PieceType(rawValue: char.uppercased()) {
            self.init(char.isUppercase ? .white : .black, type)
        } else {
            let pieceDict: [Character: Piece] = [
                "♙": Piece(.white, .pawn),
                "♘": Piece(.white, .knight),
                "♗": Piece(.white, .bishop),
                "♖": Piece(.white, .rook),
                "♕": Piece(.white, .queen),
                "♔": Piece(.white, .king),
                "♟": Piece(.black, .pawn),
                "♞": Piece(.black, .knight),
                "♝": Piece(.black, .bishop),
                "♜": Piece(.black, .rook),
                "♛": Piece(.black, .queen),
                "♚": Piece(.black, .king),
            ]
            if let piece = pieceDict[char] {
                self = piece
            } else {
                return nil
            }
        }
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        char()
    }

    public func char(unicode: Bool = true) -> String {
        if unicode {
            switch color {
            case .white:
                switch type {
                case .king: return "♔"
                case .queen: return "♕"
                case .rook: return "♖"
                case .bishop: return "♗"
                case .knight: return "♘"
                case .pawn: return "♙"
                }
            case .black:
                switch type {
                case .king: return "♚"
                case .queen: return "♛"
                case .rook: return "♜"
                case .bishop: return "♝"
                case .knight: return "♞"
                case .pawn: return "♟"
                }
            }
        } else {
            switch color {
            case .white:
                return type.rawValue.uppercased()
            case .black:
                return type.rawValue.lowercased()
            }
        }
    }
}
