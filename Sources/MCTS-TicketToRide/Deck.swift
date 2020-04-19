//
//  Deck.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation
import Squall

func newGust() -> Gust {
    return Gust(seed: UInt32(abs(Date.init(timeIntervalSinceNow: 0).hashValue) / Int(UInt32.max)))
}

struct Deck {
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

struct Hand {
    private var cards: [Color:Int]
    
    init(deck: Deck) {
        self.cards = Hand.cardArrayToDict(deck.draw(Rules.initialHandCount))
    }
    
    func cardsOf(_ color: Color) -> Int {
        return self.cards[color] ?? 0
    }
    
    func maxColorCount() -> (Color, Int) {
        var tmp: Color?
        for (color, count) in self.cards where tmp == nil || count > self.cards[tmp!] ?? 0 {
            tmp = color
        }
        if tmp == nil {
            return (.red, 0)
        }
        return (tmp!, self.cards[tmp!] ?? 0)
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
        if self.cards[color] != nil && self.cards[color]! > 0 {
            self.cards[color]! -= 1
            return self.cards[color]!
        }
        return nil
    }
    
    mutating func playCards(_ color: Color? = nil, count: Int) -> (Int, Color)? {
        var tmp = color
        if tmp == nil {
            tmp = self.maxColorCount().0
        }
        let color = tmp!
        
        // print(color, count, self.cards[color])
        if self.cards[color] != nil && self.cards[color]! >= count {
            self.cards[color]! -= count
            return (self.cards[color]!, color)
        }
        return nil
    }
}
