//
//  BaseModels.swift
//  MaxolChess
//
//  Created by Maksim Solovev on 01.08.2025.
//

public enum Const {
    public static let boardSize = 8
    public static let boardSquareCount = boardSize * boardSize
    public static let boardCoordinateCoefficients: [PieceValue] = [
    // ┌──────────────────────────────────────────────────────┐
        -0.5,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.5,
        -0.4,  -0.2,   0.0,   0.0,   0.0,   0.0,  -0.2,  -0.4,
        -0.4,   0.0,   0.1,   0.2,   0.2,   0.1,   0.0,  -0.4,
        -0.4,   0.0,   0.2,   0.25,  0.25,  0.2,   0.0,  -0.4,
        -0.4,   0.0,   0.2,   0.25,  0.25,  0.2,   0.0,  -0.4,
        -0.4,   0.0,   0.1,   0.2,   0.2,   0.1,   0.0,  -0.4,
        -0.4,  -0.2,   0.0,   0.0,   0.0,   0.0,  -0.2,  -0.4,
        -0.5,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.4,  -0.5
    // └──────────────────────────────────────────────────────┘
    //    a      b      c      d      e      f      g      h
    ]

    public static let boardCoordinateCoefficientsForWhiteKing: [PieceValue] = [
    // ┌───────────────────────────────────────────────────────┐
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,
        -0.3,  -0.4,  -0.4,  -0.5,  -0.5,  -0.4,  -0.4,  -0.3,
        -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,  -0.2,
         0.2,   0.2,   0.0,   0.0,   0.0,   0.0,   0.2,   0.2,
         0.2,   0.3,   0.1,   0.0,   0.0,   0.1,   0.3,   0.2
    // └──────────────────────────────────────────────────────┘
    //    a      b      c      d      e      f      g      h
    ]
    public static let boardCoordinateCoefficientsForBlackKing: [PieceValue] = boardCoordinateCoefficientsForWhiteKing.reversed()
}
