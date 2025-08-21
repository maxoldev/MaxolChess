//
//  Position.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 15.08.2025.
//

public enum CastlingSide {
    case kingSide
    case queenSide
}

extension CastlingSide: CustomStringConvertible {
    public var description: String {
        self == .kingSide ? "O-O" : "O-O-O"
    }
}

public struct Side {
    public let color: PieceColor
    public var pieces: [Piece] = []
    //    public var castlingRights: CastlingSide = .all
}

public struct Position {
    public private(set) var board = Board() {
        didSet {
            searchAndSetKingCoordinates()
        }
    }

    public mutating func modify(block: (_: inout Board) -> Void) {
        block(&board)
    }

    public var turn: PieceColor = .white
    public private(set) var castlingRights: [PieceColor: Set<CastlingSide>] = [.white: [], .black: []]
    public private(set) var enPassantTargetCoordinate: Coordinate?
    public var halfMoveCountSinceLastCaptureOrPawnMove = 0
    public var fullMoveIndex = 0

    public init(_ board: Board = Board(), turn: PieceColor = .white) {
        self.board = board
        self.turn = turn
        searchAndSetKingCoordinates()
    }

    private var kingCoordinatesDict = [PieceColor: Coordinate]()

    public func kingCoordinate(_ color: PieceColor) -> Coordinate? {
        kingCoordinatesDict[color]
    }

    private mutating func searchAndSetKingCoordinates() {
        for i in 0..<Const.baseBoardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = board[coordinate], piece.type == .king {
                kingCoordinatesDict[piece.color] = coordinate
            }
        }
    }

    public func applied(move: Move) -> Position {
        var newBoard = board
        var newPosition = self

        switch move {
        case let reposition as RepositionMove:
            newBoard[reposition.to] = newBoard[reposition.from]
            newBoard[reposition.from] = nil
            if reposition.piece.type == .king {
                newPosition.castlingRights[reposition.piece.color]!.removeAll()
            }

        case let capture as CaptureMove:
            newBoard[capture.to] = newBoard[capture.from]
            newBoard[capture.from] = nil

        default:
            fatalError("Not implemented: \(move)")
        }
        newPosition.board = newBoard
        return newPosition
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        self.prettyPrinted()
    }

    public func prettyPrinted(unicode: Bool = true) -> String {
        "\(board.prettyPrinted(unicode: unicode))\n\(turn) to move"
    }
}

extension Position {
    nonisolated(unsafe) public static let start = Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")!
}

extension Position {
    /**
    FEN structure is strictly definded, so we can use magic numbers here.
    
     A FEN string consists of six fields, separated by spaces:
     1. Piece Placement
     - Ranks are listed from 8th to 1st, separated by /.
     - Uppercase letters (K, Q, R, B, N, P) = White pieces.
     - Lowercase letters (k, q, r, b, n, p) = Black pieces.
     - Numbers represent empty squares (e.g., 4 = four consecutive empty squares).
    
     2. Active Color
     - w = White to move, b = Black to move.
    
     3. Castling Rights
     - K (White kingside), Q (White queenside), k (Black kingside), q (Black queenside).
     - If no castling is possible: -.
    
    4. En Passant Target
    - The square where a pawn can be captured en passant (e.g., e3 or c6).
    - If none: -.
    
    5. Halfmove Number
    - Number of half-moves (plies) since the last capture or pawn move (for the 50-move rule).
    
    6. Fullmove Number
    - Starts at 1 and increments after Black’s move.
    
    Examples:
    - Start position:
    rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
    - Position after 1.e4:
    rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1
     */
    public init?(fen: String) {
        let fields = fen.split(separator: " ").map(String.init)

        guard fields.count == 6 else { return nil }

        guard let board = Board(fenBoardSubstring: fields[0]) else {
            return nil
        }

        guard let sideToMove = PieceColor(rawValue: fields[1]) else {
            return nil
        }

        self.init(board, turn: sideToMove)

        if fields[2].contains("K") {
            castlingRights[.white]?.insert(.kingSide)
        }
        if fields[2].contains("Q") {
            castlingRights[.white]?.insert(.queenSide)
        }
        if fields[2].contains("k") {
            castlingRights[.black]?.insert(.kingSide)
        }
        if fields[2].contains("q") {
            castlingRights[.black]?.insert(.queenSide)
        }

        if fields[3] != "-" {
            enPassantTargetCoordinate = Coordinate(fields[3])
        }

        halfMoveCountSinceLastCaptureOrPawnMove = Int(fields[4]) ?? 0
        fullMoveIndex = Int(fields[5]) ?? 0

        searchAndSetKingCoordinates()
    }

    public var fenString: String {
        var castlingRightsString = ""
        if castlingRights[.white]?.contains(.kingSide) == true {
            castlingRightsString.append("K")
        }
        if castlingRights[.white]?.contains(.queenSide) == true {
            castlingRightsString.append("Q")
        }
        if castlingRights[.black]?.contains(.kingSide) == true {
            castlingRightsString.append("k")
        }
        if castlingRights[.black]?.contains(.queenSide) == true {
            castlingRightsString.append("q")
        }
        if castlingRightsString.isEmpty {
            castlingRightsString = "-"
        }

        let enPassantString = enPassantTargetCoordinate.map(String.init) ?? "-"
        
        return
            "\(board.fenString) \(turn.rawValue) \(castlingRightsString) \(enPassantString) \(halfMoveCountSinceLastCaptureOrPawnMove) \(fullMoveIndex)"
    }
}
