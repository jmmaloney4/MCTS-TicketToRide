//
//  Deck.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation
import Squall

protocol Deck {
    func draw() -> (Color, Self)
    func draw(_: Int) -> ([Color], Self)
    func discard(_: Color) -> Self
}

func newGust() -> Gust {
    return Gust(seed: UInt32(Date.init(timeIntervalSinceNow: 0).hashValue))
}

struct FixedProbabilityDeck: Deck {
    // Gust is a class type, which is what we want, that way the deck is
    // random each time we draw it, rather than giving the same color every time a state is queried.
    var rng: Gust = newGust()
    var colors: [Color]
    
    init(colors: [Color] = Color.simpleCards()) {
        self.colors = colors
    }
    
    func draw() -> (Color, FixedProbabilityDeck) {
        return (self.colors[Int(rng.random() % UInt32(self.colors.count))], self)
    }
    
    func discard(_ color: Color) -> FixedProbabilityDeck {
        return self
    }
    
    func draw(_ count: Int) -> ([Color], FixedProbabilityDeck) {
        var rv: [Color] = []
        (0..<count).forEach({ _ in rv.append(self.draw().0) })
        return (rv, self)
    }
}

struct EvenlyDistributedShufflingDeck: Deck {
    private var deck: [Color]
    private var discard: [Color] = []
    private var rng = newGust()
    
    init(colors: [Color], each: Int) {
        self.deck = []
        colors.forEach({ self.deck.append(contentsOf: Array(repeating: $0, count: each)) })
    }
    
    init(copy: EvenlyDistributedShufflingDeck) {
        self.deck = copy.deck
        self.discard = copy.discard
        self.rng = copy.rng
    }
    
    func draw() -> (Color, EvenlyDistributedShufflingDeck) {
        var copy = EvenlyDistributedShufflingDeck(copy: self)
        return (copy.deck.popLast()!, copy)
    }
    
    func draw(_ count: Int) -> ([Color], EvenlyDistributedShufflingDeck) {
        var rv: [Color] = []
        var copy = self
        for _ in 0..<count {
            let (card, new) = copy.draw()
            rv.append(card)
            copy = new
        }
        return (rv, copy)
    }
    
    func discard(_ card: Color) -> EvenlyDistributedShufflingDeck {
        var copy = EvenlyDistributedShufflingDeck(copy: self)
        copy.discard.append(card)
        return copy
    }
}

extension Array where Element == Color {
    mutating func shuffle(_ rng: Gust) {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let r: UInt64 = rng.random()
            let d: Int = numericCast(r % (numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

