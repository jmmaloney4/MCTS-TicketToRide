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

enum PlayerType {
    case mcts
    case random
}

protocol Player {
    func takeTurn(game: Game) throws -> TurnAction
    func update(game: Game, player: Int, action: TurnAction) throws
}

extension Player {
    var type: PlayerType {
        if self is MCTSAIPlayerInterface { return .mcts }
        else if self is RandomAIPlayerInterface { return .random }
        else { fatalError() }
    }
}

class Game {
    private(set) var board: Board
    private(set) var players: [Player]!
//    private var trees: [MCTSTree] = []
    private(set) var state: State!
    
    init(board: Board, deck:Deck, players: PlayerType...) throws {
        self.board = board
        self.state = State(asRootOf: self, withDeck: deck, playerCount: players.count)
        
        self.players = players.enumerated().map({
            let p = $0.offset
            switch $0.element {
            case .mcts: return MCTSAIPlayerInterface(state: state, player: p)
            case .random: return RandomAIPlayerInterface(state: state, player: p)
            }
        })
        
        try self.start()
    }
    
    func start() throws {
        while !self.state.gameOver {
            let (action, state) = self.state.asResultOfAction( try self.players[self.state.player()].takeTurn(game: self))
            print("Player (\(self.players[self.state.player()].type)) \(self.state.player()): \(action)")
            for p in players {
                try p.update(game: self, player: self.state.player(), action: action)
                // print(tree.root.state.turn)
            }
            self.state = state
        }
        let winner = self.state.calculateWinner()
        print("Winner: \(winner) (\(self.players[winner].type))")
    }
}
