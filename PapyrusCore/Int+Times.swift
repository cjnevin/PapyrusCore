//
//  Int+Times.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 3/08/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

internal extension Int {
    func times(_ task: () -> ()) {
        for _ in 0..<self {
            task()
        }
    }
    
    func times(whileTrue task: () -> (Bool)) {
        for _ in 0..<self {
            if !task() {
                break
            }
        }
    }
}
