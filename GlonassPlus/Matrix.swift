//
//  Matrix.swift
//  GlonassPlus
//
//  Created by Mac on 2/27/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation

func determ(matrix: [[Double]]) -> Double { // определитель
    
    let n: Int = matrix.count
    var temp: Double = 0   //временная переменная для хранения определителя
    var k: Int = 1     //степень
    if n == 1 {
        temp = matrix[0][0]
    } else if n == 2 {
        temp = matrix[0][0] * matrix[1][1] - matrix[1][0] * matrix[0][1]
    } else {
        for i in 0..<n {
            let temp_matr = getMinorSubmatr(matrix: matrix, indRow: 0, indCol: i)
            temp = temp + Double(k) * matrix[0][i] * determ(matrix: temp_matr)
            k = -k
        }
    }
    return temp
}
//функция вычеркивания строки и столбца
func getMinorSubmatr(matrix: [[Double]], indRow: Int, indCol: Int) -> [[Double]] {
    var temp_matr: [[Double]] = Array.init(repeating: Array.init(repeating: 0.0, count: matrix.count - 1), count: matrix.count - 1)
    var ki: Int = 0
    var kj: Int = 0
    let n: Int = matrix.count
    for i in 0..<n {
        if (i != indRow) {
            kj = 0
            for j in 0..<n {
                if (j != indCol)
                {
                    temp_matr[ki][kj] = matrix[i][j]
                    kj += 1
                }
            }
            ki += 1
        }
    }
    return temp_matr
}

func obratnayaMatrix (matrix: [[Double]]) -> [[Double]] {
    var A_obr: [[Double]] = Array.init(repeating: Array.init(repeating: 0.0, count: matrix.count), count: matrix.count)
    let n = matrix.count
    let det = determ(matrix: matrix)
    if det != 0 {
        for i in 0..<n {
            for j in 0..<n  {
                let temp_matr = getMinorSubmatr(matrix: matrix, indRow: j, indCol: i)
                A_obr[i][j] = pow(-1.0, Double(i + j + 2)) * determ(matrix: temp_matr) / det
            }
        }
    }
    return A_obr
}

func trasnpose(matrix: [[Double]]) -> [[Double]] {

    var resultMatrix: [[Double]] = Array.init(repeating: Array.init(repeating: 0.0, count: matrix.count), count: matrix[0].count)

    for i in 0..<matrix.count {
        for j in 0..<matrix[0].count {
            
            resultMatrix[j][i] = matrix[i][j]
        }
    }
    
    return resultMatrix
}
