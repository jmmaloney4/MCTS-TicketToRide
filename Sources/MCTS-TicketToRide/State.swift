//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation
import Squall

struct Hand {
    private var cards: [Color:Int]
}

struct Player {
    var hand: Hand
    var traincars: Int
}

struct State {
    var deck: Deck = FixedProbabilityDeck()
    var players: [Player]
}

struct Game {
    private(set) var players: [Player]
    private(set) var board: Board
    private(set) var deck: Deck
    private(set) var rules: Rules
    
    init(board: Board, deck: Deck, rules: Rules, players: Player...) {
        self.init(board: board, deck: deck, rules: rules, players: players)
    }
    
    init(board: Board, deck: Deck, rules: Rules, players: [Player]) {
        self.players = players
        self.board = board
        self.deck = deck
        self.rules = rules
    }
    
    mutating func start() {
        for (i, _) in players.enumerated() {
            // players[i].hand = Hand(self.deck.draw(count: self.rules.initialHandCount))
        }
    }
}

protocol PlayerController {
    
}
