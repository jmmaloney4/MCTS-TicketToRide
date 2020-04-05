//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation
import Squall

struct Rules {
    var initialHandCount = 3
}

protocol Deck {
    func draw() -> Color
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
}

struct Hand {
    private var cards: [Color:Int]
}

struct Player {
    private(set) var hand: Hand
    private(set) var traincars: Int
}

struct State {
    var deck: Deck = FixedProbabilityDeck()
    var players: [Player]
}

struct Game {
    private(set) var players: [Player]
    private(set) var board: Board
    
    init(board: Board, players: Player...) {
        self.init(board: board, players: players)
    }
    
    init(board: Board, players: [Player]) {
        self.players = players
        self.board = board
    }
    
    func start() {
        
    }
}

protocol PlayerController {
    
}
