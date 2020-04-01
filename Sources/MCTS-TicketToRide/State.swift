//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation

struct Deck {
    var cards: [Color] = []

    init(colors: [Color] = Color.allCards(), cardsPerColor: Int = 8) {
        for color in colors {
            for _ in 0 ..< cardsPerColor {
                cards.append(color)
            }
        }
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
    var deck: Deck = Deck()
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
