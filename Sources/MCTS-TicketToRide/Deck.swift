//
//  Deck.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation
import Squall

func newGust() -> Gust {
    return Gust(seed: UInt32(Date.init(timeIntervalSinceNow: 0).hashValue))
}

struct Deck{
    // Gust is a class type, which is what we want, that way the deck is
    // random each time we draw it, rather than giving the same color every time a state is queried.
    var rng: Gust = newGust()
    var colors: [Color]
    
    init(colors: [Color] = Color.simpleCards()) {
        self.colors = colors
    }
    
    func draw() -> Color {
        return self.colors[Int(rng.random() % UInt32(self.colors.count))]
    }
    
    func draw(_ count: Int) -> [Color] {
        var rv: [Color] = []
        (0..<count).forEach({ _ in rv.append(self.draw()) })
        return rv
    }
}
