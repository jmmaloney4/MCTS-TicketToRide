//
//  Deck.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation
import Squall

protocol Deck {
    func draw() -> Color
    func draw(count: Int) -> [Color]
}

struct FixedProbabilityDeck: Deck {
    var rng: Gust = Gust(seed: UInt32(Date.init(timeIntervalSinceNow: 0).hashValue))
    var colors: [Color]
    
    init(colors: [Color] = Color.simpleCards()) {
        self.colors = colors
    }
    
    func draw() -> Color {
        self.colors[Int(rng.random() % UInt32(self.colors.count))]
    }
    
    func draw(count: Int) -> [Color] {
        var rv: [Color] = []
        (0..<count).forEach({ _ in rv.append(self.draw()) })
        return rv
    }
}
