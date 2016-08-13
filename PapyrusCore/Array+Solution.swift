//
//  Array+Solution.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 13/08/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

internal extension Array where Element: SolutionType {

    func best(forDifficulty difficulty: Difficulty = .hard) -> Element? {
        guard count > 0 else {
            return nil
        }
        let sorted = self.sorted(by: { $0.score > $1.score })
        let highestScore = sorted.first!
        if difficulty == .hard || sorted.count == 1 {
            return highestScore
        }
        let scaled = Double(highestScore.score) * difficulty.rawValue
        func diff(solution: Element) -> Double {
            return abs(scaled - Double(solution.score))
        }
        return sorted.min(by: { diff(solution: $0) < diff(solution: $1) })
    }
    
}
