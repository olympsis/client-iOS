//
//  MLAlgorithms.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/5/25.
//

import Foundation

/// Levenshtein distance or edit distance is a computer science algorithm for calculating the similarity of two strings.
/// It calculates the minimum number of inserts, subsitutions removals and no actions needed to convert a string the other.
/// - **Parameters**:
///     - stringA: the first `String` we want to compare
///     - stringB: the second `String` we want to compare
///
/// - **Returns**: an integer of the similarity score
func levenshteinDistance(stringA: String, stringB: String) -> Int {
    let arrayA = Array(stringA)
    let arrayB = Array(stringB)
    
    let m = arrayA.count
    let n = arrayB.count
    
    // Create a matrix with dimensions (m+1) x (n+1)
    var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
    
    // Initialize first row and column
    for i in 0...m {
        matrix[i][0] = i
    }
    for j in 0...n {
        matrix[0][j] = j
    }
    
    // Fill the matrix using dynamic programming
    for i in 1...m {
        for j in 1...n {
            let cost = arrayA[i-1] == arrayB[j-1] ? 0 : 1
            matrix[i][j] = min(
                matrix[i-1][j] + 1,      // deletion
                matrix[i][j-1] + 1,      // insertion
                matrix[i-1][j-1] + cost  // substitution
            )
        }
    }
    
    return matrix[m][n]
}
