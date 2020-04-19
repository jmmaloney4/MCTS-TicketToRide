//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation
import Squall

struct PlayerState {
    var hand: Hand
    var traincars: Int
    var tracksOwned: [Track]
    
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

struct State {
    private(set) var game: Game
    private(set) var deck: Deck
    private(set) var players: [PlayerState] = []
    private(set) var turn: Int = 0
    
    private(set) var lastPlayer: Int? = nil
    var lastRound: Bool { return self.lastPlayer != nil }
    var gameOver: Bool { return lastRound && self.lastTurn() == lastPlayer }
    
    init(asRootOf game: Game, withDeck deck: Deck) {
        self.game = game
        self.deck = deck
        for _ in game.players {
            self.players.append(PlayerState(hand: Hand(deck: self.deck)))
        }
    }
    
    private func ownedTracks() -> [Track] {
        self.players.reduce([]) { (res: [Track], player) -> [Track] in
            var res = res
            res.append(contentsOf: player.tracksOwned)
            return res
        }
    }
    
    private func unownedTracks() -> [Track] {
        let owned = self.ownedTracks()
        return self.game.board.allTracks().filter({ !owned.contains($0) })
    }
    
    private func tracksBuildable(ByPlayer p: Int) -> [Track] {
        return self.unownedTracks().filter({
            guard $0.length <= self.players[p].traincars else { return false }
            switch $0.color {
            case .unspecified: return $0.length <= self.players[p].hand.maxColorCount().1
            default: return $0.length <= self.players[p].hand.cardsOf($0.color)
            }
        })
    }
    
    func getLegalMoves() -> [TurnAction] {
        var rv: [TurnAction] = [.draw]
        for track in tracksBuildable(ByPlayer: turn) {
            rv.append(.build(track))
        }
        return rv
    }
    
    func nextTurn() -> Int {
        if self.turn == players.count - 1 {
            return 0
        } else {
            return self.turn + 1
        }
    }
    
    func lastTurn() -> Int {
        if self.turn == 0 {
            return players.count - 1
        } else {
            return self.turn - 1
        }
    }
    
    func asResultOfAction(_ action: TurnAction) -> State {
        var rv = self
        switch action {
        case .draw:
            _ = rv.players[turn].hand.addCard(rv.deck.draw())
        case .build(let track):
            guard track.length <= rv.players[turn].traincars else {
                fatalError()
            }
            rv.players[turn].traincars -= track.length
            if rv.players[turn].traincars <= Rules.traincarCutoff {
                rv.lastPlayer = rv.lastTurn()
            }
            
            switch track.color {
            case .unspecified:
                guard rv.players[turn].hand.playCards(count: track.length) != nil else {
                    fatalError()
                }
            default:
                guard rv.players[turn].hand.playCards(track.color, count: track.length) != nil else {
                    fatalError()
                }
            }
        }
        
        rv.turn = rv.nextTurn()
        return rv
    }
    
    func calculateWinner() -> Int {
        var points: [Int] = Array(repeating: 0, count: self.players.count)
        for (k, p) in self.players.enumerated() {
            points[k] += p.tracksOwned.reduce(0, { $0 + $1.points()! })
        }
        return points.firstIndex(of: points.max()!)!
    }
}

protocol Player {
    func takeTurn(tree: MCTSTree, game: Game) throws -> TurnAction
}

class MCTSAIPlayerInterface: Player {
    func takeTurn(tree: MCTSTree, game: Game) throws -> TurnAction {
        let rng = newGust()
        for _ in 0..<10 {
            try tree.runSimulation(rng: rng)
        }
        return tree.pickMove()
    }
}
