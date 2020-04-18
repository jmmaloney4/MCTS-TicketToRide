//
//  Game.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation

enum TurnAction: Hashable {
    case draw
    case build(Track)
}

class Game {
    private(set) var board: Board
    private(set) var players: [Player]
    private var trees: [MCTSTree] = []
    private(set) var state: State!
    
    init(board: Board, deck:Deck, players: Player...) throws {
        self.board = board
        self.players = players
        self.state = State(asRootOf: self, withDeck: deck)
        
        for k in 0..<players.count {
            self.trees.append(MCTSTree(self.state, forPlayer: k))
        }
        
        try self.start()
    }
    
    func start() throws {
        for p in state.players {
            print(p.hand)
        }
        for (k, p) in players.enumerated() {
            print(try p.takeTurn(tree: trees[k], game: self))
        }
        for tree in self.trees {
            print(tree.root.computeUCT())
        }
    }
}
