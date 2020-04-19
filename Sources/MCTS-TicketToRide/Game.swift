//
//  Game.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/5/20.
//

import Foundation

enum TurnAction: Hashable {
    case draw(Color)
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
        while !self.state.gameOver {
            var action = try self.players[self.state.turn].takeTurn(tree: trees[self.state.turn], game: self)
            print(action, self.state.turn)
            (action, self.state) = self.state.asResultOfAction(action)
            print(action)
            guard state != nil else { fatalError() }
            for tree in trees {
                try tree.updateRoot(action)
                print(tree.root.state.turn)
            }
        }
        print("Winner: \(self.state.calculateWinner())")
    }
}
