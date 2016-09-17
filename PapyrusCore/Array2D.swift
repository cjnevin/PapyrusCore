//
//  Array2D.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 17/09/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

func ==<T: Hashable>(lhs: Array2D<T>, rhs: Array2D<T>) -> Bool {
    return lhs.array == rhs.array
}

struct Array2D<T: Hashable>: Equatable {
    fileprivate var array: [T]
    let columns: Int
    let rows: Int
    
    init(columns: Int, rows: Int, initialValue: T) {
        self.columns = columns
        self.rows = rows
        array = .init(repeating: initialValue, count: rows * columns)
    }
    
    subscript(column: Int, row: Int) -> T {
        get {
            return array[row * columns + column]
        }
        set {
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            
            array[row * columns + column] = newValue
        }
    }
}
