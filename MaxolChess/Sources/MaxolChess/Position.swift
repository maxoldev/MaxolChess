//
//  Position.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 15.08.2025.
//

public enum CastlingSide: Sendable {
    case kingSide
    case queenSide
}

extension CastlingSide: CustomStringConvertible {
    public var description: String {
        self == .kingSide ? "O-O" : "O-O-O"
    }
}

public struct Position: Equatable, Sendable {
    public static let start = Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")!

    public private(set) var board: Board

    public mutating func modify(block: (_: inout Board) -> Void) {
        block(&board)
    }

    public var sideToMove: PieceColor

    public typealias CastlingRights = [PieceColor: Set<CastlingSide>]
    public private(set) var castlingRights: CastlingRights = [.white: [], .black: []]

    public private(set) var enPassantTargetCoordinate: Coordinate?
    /// Number of half-moves (plies) since the last capture or pawn move (for the 50-move rule).
    public var halfMoveCountSinceLastCaptureOrPawnMove = 0
    /// Starts at 1 and increments after Black’s move.
    public var fullMoveIndex = 1

    public init(_ board: Board, sideToMove: PieceColor) {
        self.board = board
        self.sideToMove = sideToMove
        searchAndSetKingCoordinates()
    }

    private var kingCoordinatesDict = [PieceColor: Coordinate]()

    public func kingCoordinate(_ color: PieceColor) -> Coordinate? {
        kingCoordinatesDict[color]
    }

    private mutating func searchAndSetKingCoordinates() {
        for i in 0..<Const.boardSquareCount {
            let coordinate = Coordinate(i)
            if let piece = board[coordinate], piece.type == .king {
                kingCoordinatesDict[piece.color] = coordinate
            }
        }
    }

    public var opposite: Position {
        var newPosition = self
        newPosition.sideToMove = sideToMove.opposite
        return newPosition
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        self.multiline(unicode: Config.shared.log.useUnicodePieceNotation)
    }
}

// MARK: - FEN & multiline
extension Position {
    /**
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
        // FEN structure is strictly definded, so we can use magic numbers here.
        let fields = fen.split(separator: " ").map(String.init)

        guard fields.count == 6 else { return nil }

        guard let board = Board(fenBoardSubstring: fields[0]) else {
            return nil
        }

        self.init(board, sideToMove: .white)

        if !loadState(fromFenStateFields: Array(fields[1..<6])) {
            return nil
        }
    }

    public func multiline(unicode: Bool = Config.shared.log.useUnicodePieceNotation) -> String {
        "\(board.multiline(unicode: unicode))\n\(fenStateString)"
    }

    /*
      ┌───────────────┐
    8  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
    7  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
    6  . . . . . . . .
    5  . . . . . . . .
    4  . . . . . . . .
    3  . . . . . . . .
    2  ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
    1  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
      └───────────────┘
       a b c d e f g h
    w KQkq - 0 1

     OR

      ┌───────────────┐
    8  r n b q k b n r
    7  p p p p p p p p
    6  . . . . . . . .
    5  . . . . . . . .
    4  . . . . . . . .
    3  . . . . . . . .
    2  P P P P P P P P
    1  R N B Q K B N R
      └───────────────┘
       a b c d e f g h
    w KQkq - 0 1
    */
    public init?(multiline: String) {
        guard let board = Board(multiline: multiline) else {
            return nil
        }
        guard let fromFenStateFields = multiline.split(separator: "\n").last?.split(separator: " ").map(String.init) else {
            return nil
        }

        self.init(board, sideToMove: .white)

        if !loadState(fromFenStateFields: fromFenStateFields) {
            return nil
        }
    }

    private mutating func loadState(fromFenStateFields fields: [String]) -> Bool {
        guard fields.count == 5 else {
            return false
        }

        guard let sideToMove = PieceColor(rawValue: fields[0]) else {
            return false
        }

        self.sideToMove = sideToMove

        if fields[1].contains("K") {
            castlingRights[.white]!.insert(.kingSide)
        }
        if fields[1].contains("Q") {
            castlingRights[.white]!.insert(.queenSide)
        }
        if fields[1].contains("k") {
            castlingRights[.black]!.insert(.kingSide)
        }
        if fields[1].contains("q") {
            castlingRights[.black]!.insert(.queenSide)
        }

        if fields[2] != "-" {
            enPassantTargetCoordinate = Coordinate(fields[3])
        }

        halfMoveCountSinceLastCaptureOrPawnMove = Int(fields[3]) ?? 0
        fullMoveIndex = Int(fields[4]) ?? 0

        return true
    }

    public var fenString: String {
        "\(board.fenString) \(fenStateString)"
    }

    public var fenBoardString: String {
        return board.fenString
    }

    public var fenStateString: String {
        var castlingRightsString = ""
        if castlingRights[.white]!.contains(.kingSide) {
            castlingRightsString.append("K")
        }
        if castlingRights[.white]!.contains(.queenSide) {
            castlingRightsString.append("Q")
        }
        if castlingRights[.black]!.contains(.kingSide) {
            castlingRightsString.append("k")
        }
        if castlingRights[.black]!.contains(.queenSide) {
            castlingRightsString.append("q")
        }
        if castlingRightsString.isEmpty {
            castlingRightsString = "-"
        }

        let enPassantString = enPassantTargetCoordinate.map(String.init) ?? "-"

        return
            "\(sideToMove.rawValue) \(castlingRightsString) \(enPassantString) \(halfMoveCountSinceLastCaptureOrPawnMove) \(fullMoveIndex)"
    }
}

extension Position {
    public func applied(move: Move) -> Position {
        var newBoard = board
        var newPosition = self

        newPosition.halfMoveCountSinceLastCaptureOrPawnMove += 1
        if self.sideToMove == .black {
            // Increments after Black's moves
            newPosition.fullMoveIndex += 1
        }

        switch move {
        case let repositionMove as RepositionMove:
            assert(repositionMove.piece.color == sideToMove)
            newBoard[repositionMove.to] = newBoard[repositionMove.from]
            newBoard[repositionMove.from] = nil
            if repositionMove.piece.type == .king {
                newPosition.castlingRights[sideToMove]!.removeAll()
                newPosition.kingCoordinatesDict[sideToMove] = repositionMove.to
            }
            if repositionMove.piece.type == .rook {
                if repositionMove.from.x == 0 {
                    newPosition.castlingRights[sideToMove]!.remove(.queenSide)
                } else if repositionMove.from.x == Const.boardSize - 1 {
                    newPosition.castlingRights[sideToMove]!.remove(.kingSide)
                }
            }
            if repositionMove.piece.type == .pawn {
                newPosition.halfMoveCountSinceLastCaptureOrPawnMove = 0
            }

        case let captureMove as CaptureMove:
            assert(captureMove.piece.color == sideToMove)
            newBoard[captureMove.to] = newBoard[captureMove.from]
            newBoard[captureMove.from] = nil
            newPosition.halfMoveCountSinceLastCaptureOrPawnMove = 0
            if captureMove.piece.type == .king {
                newPosition.castlingRights[sideToMove]!.removeAll()
                newPosition.kingCoordinatesDict[sideToMove] = captureMove.to
            }
            if captureMove.piece.type == .rook {
                if captureMove.from.x == 0 {
                    newPosition.castlingRights[sideToMove]!.remove(.queenSide)
                } else if captureMove.from.x == Const.boardSize - 1 {
                    newPosition.castlingRights[sideToMove]!.remove(.kingSide)
                }
            }

        case let promotionMove as PromotionMove:
            assert(promotionMove.piece.color == sideToMove)
            newBoard[promotionMove.to] = promotionMove.newPiece
            newBoard[promotionMove.from] = nil
            newPosition.halfMoveCountSinceLastCaptureOrPawnMove = 0

        case let castlingMove as CastlingMove:
            // TODO: throw an error when needed
            assert(!newPosition.castlingRights[sideToMove]!.isEmpty)

            let kingCoord = newPosition.kingCoordinate(sideToMove)!
            newPosition.castlingRights[sideToMove]!.removeAll()

            let rookCoord: Coordinate
            let newKingCoord: Coordinate
            let newRookCoord: Coordinate
            switch castlingMove.side {
            case .kingSide:
                rookCoord = kingCoord.rightmost
                newKingCoord = kingCoord.advancedBy(2, 0)!
                newRookCoord = newKingCoord.advancedBy(-1, 0)!

            case .queenSide:
                rookCoord = kingCoord.leftmost
                newKingCoord = kingCoord.advancedBy(-2, 0)!
                newRookCoord = newKingCoord.advancedBy(1, 0)!
            }
            newBoard[kingCoord] = nil
            newBoard[rookCoord] = nil
            newBoard[newKingCoord] = Piece(sideToMove, .king)
            newBoard[newRookCoord] = Piece(sideToMove, .rook)
            newPosition.kingCoordinatesDict[sideToMove] = newKingCoord

        default:
            fatalError("Not implemented: \(move)")
        }

        newPosition.board = newBoard
        newPosition.sideToMove = sideToMove.opposite

        return newPosition
    }
}
