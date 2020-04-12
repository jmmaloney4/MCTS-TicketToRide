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

struct PlayerState {
    var hand: Hand
    var traincars: Int
    var tracksOwned: [Int]
    
    init(copy: PlayerState) {
        self.hand = copy.hand
        self.traincars = copy.traincars
        self.tracksOwned = copy.tracksOwned
    }
}

class MCTSTree {
    private(set) var root: MCTSNode = MCTSNode()
}

class MCTSNode {
    private(set) var children: [MCTSNode] = []
    private(set) var state: State
}

struct State {
    private(set) var deck: Deck
    private(set) var players: [PlayerState]
    
    init(deck: Deck, players: [Player]) {
        self.deck = deck
    }
}

protocol Player {
    
}

class Game {
    var board: Board
    var players: [Player]
    var tree: MCTSTree
    
    init(board: Board, deck:Deck, players: Player...) {
        self.board = board
        self.players = players
        
        
    }
}
