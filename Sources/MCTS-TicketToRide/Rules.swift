//
//  Rules.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation

struct Rules {
    static var initialHandCount = 4         // Europe Rules: 4
    static var initialTraincarCount = 30    // Eurpoe Rules: 45
    static var traincarCutoff = 3
    
    static var uctExplorationConstant = 0.4
    static var mctsIterations = 750
    static let turnCutoff: Int? = 100_000
}
