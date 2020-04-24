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
    case mcts(Int, Double)
    case random
    case big
}

protocol Player {
    func takeTurn(game: Game) throws -> TurnAction
    func update(game: Game, player: Int, action: TurnAction) throws
    
    var type: PlayerType { get }
}

class Game {
    private(set) var board: Board
    private(set) var players: [Player]!
    private(set) var state: State!
    private(set) var rules: Rules
    
    init(board: Board, deck: Deck, rules: Rules, players: [PlayerType]) throws {
        self.board = board
        self.rules = rules
        self.state = State(asRootOf: self, withDeck: deck, playerCount: players.count)
        
        self.players = players.enumerated().map({
            let p = $0.offset
            switch $0.element {
            case .mcts(let iter, let C): return MCTSAIPlayerInterface(state: state, player: p, iterations: iter, explore: C)
            case .random: return RandomAIPlayerInterface(state: state, player: p)
            case .big: return BigTrackAIPlayerInterface(state: state, player: p)
            }
        })
    }
    
    func start() throws -> (Int, Bool, Int, [Int]) {
        while !self.state.gameOver {
            let (action, state) = self.state.asResultOfAction( try self.players[self.state.player()].takeTurn(game: self))
            // print("Player (\(self.players[self.state.player()].type)) \(self.state.player()): \(action)")
            self.state = state
            for p in players {
                try p.update(game: self, player: self.state.player(), action: action)
            }
        }

        return self.state.calculateWinner()
    }
}
