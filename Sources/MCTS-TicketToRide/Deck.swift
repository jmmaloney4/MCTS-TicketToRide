//
//  Deck.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation
import Squall

class Deck {
    // Gust is a class type, which is what we want, that way the deck is
    // random each time we draw it, rather than giving the same color every time a state is queried.
    var rng: RNG
    var colors: [Color]
    
    
    init(colors: [Color] = Color.simpleCards()) {
        self.colors = colors
        self.rng = makeRNG()
    }
    
    func draw() -> Color {
        return self.colors.randomElement(using: &self.rng)!
    }
    
    func draw(_ count: Int) -> [Color] {
        var rv: [Color] = []
        (0..<count).forEach({ _ in rv.append(self.draw()) })
        return rv
    }
}

struct Hand: Equatable {
    private var cards: [Color:Int]
    
    init(deck: Deck, count: Int) {
        self.cards = Hand.cardArrayToDict(deck.draw(count))
    }
    
    func cardsOf(_ color: Color) -> Int {
        return self.cards[color] ?? 0
    }
    
    func maxColorCount() -> (Color, Int) {
        if self.cards.count == 0 { return (.red, 0) }
        let max = self.cards.values.max()!
        let options = self.cards.filter({ $0.value == max }).map({ $0.key }).sorted(by: { $0.rawValue < $1.rawValue })
        return (options[0], max)
    }
    
    private static func cardArrayToDict(_ arr: [Color]) -> [Color:Int] {
        var rv: [Color:Int] = [:]
        for color in arr {
            if rv[color] != nil {
                rv[color]! += 1
            } else {
                rv[color] = 1
            }
        }
        return rv
    }
    
    mutating func addCard(_ color: Color) -> Int {
        if self.cards[color] != nil {
            self.cards[color]! += 1
        } else {
            self.cards[color] = 1
        }
        return self.cards[color]!
    }
    
    mutating func removeCard(_ color: Color) -> Int? {
        if self.cards[color] != nil, self.cards[color]! > 0 {
            self.cards[color]! -= 1
            return self.cards[color]!
        }
        return nil
    }
    
    mutating func playCards(_ color: Color, count: Int) -> Bool {
        if self.cards[color] != nil, self.cards[color]! >= count {
            self.cards[color]! -= count
            return true
        }
        
        print(self)
        print(color)
        print(count)
        return false
    }
}
