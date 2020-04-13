//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation
import Squall

func cardArrayToDict(_ arr: [Color]) -> [Color:Int] {
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

struct Hand {
    private var cards: [Color:Int]
    
    init(deck: Deck) {
        self.cards = cardArrayToDict(deck.draw(Rules.initialHandCount))
    }
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
    
    init(hand: Hand, traincars: Int = Rules.initialTraincarCount) {
        self.hand = hand
        self.traincars = traincars
        self.tracksOwned = []
    }
}

class MCTSTree {
    private(set) var root: MCTSNode
    
    init(_ state: State) {
        self.root = MCTSNode(withState: state)
    }
}

class MCTSNode {
    private(set) var children: [MCTSNode] = []
    private(set) var state: State
    
    init(withState state: State) {
        self.state = state
    }
    
    init(asChildOf parent: MCTSNode) {
        self.state = parent.state
        parent.children.append(self)
    }
}

struct State {
    private(set) var deck: Deck
    private(set) var players: [PlayerState] = []
    
    init(deck: Deck, players: [Player]) {
        self.deck = deck
        for _ in players {
            self.players.append(PlayerState(hand: Hand(deck: self.deck)))
        }
    }
}

protocol Player {
    
}

class Game {
    var board: Board
    var players: [Player]
    var tree: MCTSTree
    var state: State
    
    init(board: Board, deck:Deck, players: Player...) {
        self.board = board
        self.players = players
        
        self.state = State(deck: deck, players: self.players)
        
        self.tree = MCTSTree(self.state)
    }
}
