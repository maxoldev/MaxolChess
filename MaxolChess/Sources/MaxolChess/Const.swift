//
//  BaseModels.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 01.08.2025.
//

public enum Const {
    public static let boardSize = 8
    public static let boardSquareCount = boardSize * boardSize
    public static let unicodePieces = false
    public static let boardCoordinateCoefficients: [PieceValue] = [
    // ┌──────────────────────────────────────────────────────┐
        -0.5,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.5,  // 8
        -0.4,  -0.2,   0.0,   0.0,   0.0,   0.0,  -0.2,  -0.4,  // 7
        -0.4,   0.0,   0.1,   0.2,   0.2,   0.1,   0.0,  -0.4,  // 6
        -0.4,   0.0,   0.2,   0.25,  0.25,  0.2,   0.0,  -0.4,  // 5
        -0.4,   0.0,   0.2,   0.25,  0.25,  0.2,   0.0,  -0.4,  // 4
        -0.4,   0.0,   0.1,   0.2,   0.2,   0.1,   0.0,  -0.4,  // 3
        -0.4,  -0.2,   0.0,   0.0,   0.0,   0.0,  -0.2,  -0.4,  // 2
        -0.5,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.5   // 1
    // └──────────────────────────────────────────────────────┘
    //    a      b      c      d      e      f      g      h
    ]

    public static let boardCoordinateCoefficientsForWhiteKing: [PieceValue] = [
    // ┌───────────────────────────────────────────────────────┐
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,  // 8
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,  // 7
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,  // 6
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,  // 5
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,  // 4
        -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  // 3
         0.2,   0.2,   0.0,   0.0,   0.0,   0.0,   0.2,   0.2,  // 2
         0.2,   0.3,   0.1,   0.0,   0.0,   0.1,   0.3,   0.2   // 1
    // └──────────────────────────────────────────────────────┘
    //    a      b      c      d      e      f      g      h
    ]
    public static let boardCoordinateCoefficientsForBlackKing: [PieceValue] = boardCoordinateCoefficientsForWhiteKing.reversed()
}
