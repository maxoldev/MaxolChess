//
//  Board.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 15.08.2025.
//

public typealias Square = Piece?

/// The game is played on a square board of rows (called ranks, coordinate Y) and columns (called files, coordinate X)
public struct Board: Equatable, Sendable {
    private var squares: [Square]

    public init(squares: [Square] = Array(repeating: nil, count: Const.baseBoardSize * Const.baseBoardSize)) {
        self.squares = squares
    }

    public init(pieces: (piece: Piece, coordinate: Coordinate)...) {
        self.init()

        for (piece, coordinate) in pieces {
            self[coordinate] = piece
        }
    }

    public subscript(_ coordinate: Coordinate) -> Square {
        get {
            return self[coordinate.x, coordinate.y]
        }
        set {
            self[coordinate.x, coordinate.y] = newValue
        }
    }

    public subscript(_ fileIndex: Int, _ rankIndex: Int) -> Square {
        get {
            precondition(
                rankIndex < Const.baseBoardSize && fileIndex < Const.baseBoardSize,
                "Coordinates must be in range [0..<\(Const.baseBoardSize)]"
            )
            return self.squares[rankIndex * Const.baseBoardSize + fileIndex]
        }
        set {
            precondition(
                rankIndex < Const.baseBoardSize && fileIndex < Const.baseBoardSize,
                "Coordinates must be in range [0..<\(Const.baseBoardSize)]"
            )
            self.squares[rankIndex * Const.baseBoardSize + fileIndex] = newValue
        }
    }

    public subscript(_ coordinateString: String) -> Square {
        get {
            precondition(
                coordinateString.count == 2,
                "Coordinates must be two characters long (e.g. 'e2')"
            )
            let coordinateString = coordinateString.lowercased()
            let fileIndex = Int(coordinateString.unicodeScalars.first!.value - 97)
            let rankIndex = Int(coordinateString.unicodeScalars.last!.value - 49)
            return self[fileIndex, rankIndex]
        }
        set {
            precondition(
                coordinateString.count == 2,
                "Coordinates must be two characters long (e.g. 'e2')"
            )
            let coordinateString = coordinateString.lowercased()
            let fileIndex = Int(coordinateString.unicodeScalars.first!.value - 97)
            let rankIndex = Int(coordinateString.unicodeScalars.last!.value - 49)
            self[fileIndex, rankIndex] = newValue
        }
    }
}

extension Board: Sequence {
    public func makeIterator() -> AnyIterator<(Square, Coordinate)> {
        var idx = 0
        return AnyIterator {
            guard idx < squares.count else { return nil }
            defer { idx += 1 }
            return (squares[idx], Coordinate(idx))
        }
    }
}

extension Board {
    public static let start = Board(fenBoardSubstring: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")!

    public init?(fenBoardSubstring: String) {
        let rankStrings = fenBoardSubstring.split(separator: "/").map(String.init)
        guard rankStrings.count == Const.baseBoardSize else { return nil }

        var rankArray = [[Square]]()
        for (rankIndex, rankString) in rankStrings.reversed().enumerated() {
            guard let rank = Self.rank(fenSubstring: rankString) else {
                print("Invalid rank #\(rankIndex + 1) \(rankString)")
                return nil
            }
            rankArray.append(rank)
        }
        self.init(squares: rankArray.flatMap { $0 })
    }

    static func rank(fenSubstring: String) -> [Square]? {
        var rankSquares: [Square] = []

        for char in fenSubstring {
            switch char {
            case let c where ("1"..."\(Const.baseBoardSize)").contains(String(c)):
                rankSquares.append(contentsOf: repeatElement(nil, count: Int(String(c))!))

            default:
                guard let piece = Piece(char) else {
                    print("Invalid symbol \(char) in rank \(rankSquares)")
                    return nil
                }
                rankSquares.append(piece)
            }
        }
        guard rankSquares.count == Const.baseBoardSize else {
            print("Invalid square count")
            return nil
        }

        return rankSquares
    }

    public var ranks: [[Square]] {
        stride(from: 0, to: Const.baseBoardSize, by: 1).map { (rankIndex) -> [Square] in
            return Array(squares[rankIndex * Const.baseBoardSize..<rankIndex * Const.baseBoardSize + Const.baseBoardSize])
        }
    }

    public var fenString: String {
        var rankStrings = [String]()
        for rank in ranks.reversed() {
            var fenRank = ""
            var emptySquareCount = 0
            for square in rank {
                if let piece = square {
                    if emptySquareCount > 0 {
                        fenRank.append(String(emptySquareCount))
                    }
                    emptySquareCount = 0
                    fenRank.append(piece.char(unicode: false))
                } else {
                    emptySquareCount += 1
                }
            }
            if emptySquareCount > 0 {
                fenRank.append(String(emptySquareCount))
            }
            rankStrings.append(fenRank)
        }
        return String(rankStrings.joined(separator: "/"))
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        self.prettyPrinted()
    }

    public func prettyPrinted(unicode: Bool = Config.unicodePieceNotation) -> String {
        let main: String = ranks.enumerated().reversed().map { index, rank in
            "\(index + 1)  " + rank.map { $0.map { $0.char(unicode: unicode) } ?? "." }.joined(separator: " ") + " "
        }.joined(separator: "\n")

        return """
            
              ┌───────────────┐
            \(main)
              └───────────────┘
               a b c d e f g h 
            """
    }

    public init?(prettyPrinted: String) {
        guard let openBoardIdx = prettyPrinted.firstIndex(of: "┌"), let closeBoardIdx = prettyPrinted.firstIndex(of: "┘") else {
            print("┌ and ┘ not found")
            return nil
        }
        let prettyPrinted = prettyPrinted[openBoardIdx...closeBoardIdx].filter { "pnbrqkPNBRQK♙♘♗♖♕♔♟♞♝♜♛♚.\n".contains($0) }
        let rankStrings = prettyPrinted.split(separator: "\n").map(String.init)
        guard rankStrings.count == Const.baseBoardSize else { return nil }

        var squares = [Square]()
        for (rankIndex, rankString) in rankStrings.reversed().enumerated() {
            guard rankString.count == Const.baseBoardSize else {
                print("Invalid square count in rank \(rankIndex)")
                return nil
            }
            squares.append(contentsOf: rankString.map { Piece($0) })
        }
        
        self.init(squares: squares)
    }
}
