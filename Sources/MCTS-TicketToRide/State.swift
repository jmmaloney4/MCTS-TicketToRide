//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation
import Squall
import Dispatch

struct PlayerState: Equatable {
    var hand: Hand
    var traincars: Int
    var tracksOwned: [Track]
    
    init(copy: PlayerState) {
        self.hand = copy.hand
        self.traincars = copy.traincars
        self.tracksOwned = copy.tracksOwned
    }
    
    init(hand: Hand, traincars: Int) {
        self.hand = hand
        self.traincars = traincars
        self.tracksOwned = []
    }
    
    static func == (lhs: PlayerState, rhs: PlayerState) -> Bool {
        return lhs.hand == rhs.hand && lhs.traincars == rhs.traincars && lhs.tracksOwned == rhs.tracksOwned
    }
}

struct State: Equatable {
    private(set) var game: Game
    private(set) var deck: Deck
    private(set) var players: [PlayerState]
    private var turn: Int
    
    private(set) var lastPlayer: Int? = nil
    var lastRound: Bool { return self.lastPlayer != nil }
    var gameOver: Bool {
        if TURN_CUTOFF != nil, turn > TURN_CUTOFF! {
            print("Terminating Game with \(turn) turns played.")
            return true
        }
        return (lastRound && self.previousPlayer() == lastPlayer)
    }
    
    init(asRootOf game: Game, withDeck deck: Deck, playerCount: Int) {
        self.game = game
        self.deck = deck
        self.turn = 0
        self.players = []
        for _ in 0..<playerCount {
            self.players.append(PlayerState(hand: Hand(deck: self.deck, count: game.rules.initialHandCount), traincars: game.rules.initialTraincarCount))
        }
    }
    
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.game === rhs.game && lhs.turn == rhs.turn && lhs.players == rhs.players
    }
    
    func ownedTracks() -> [Track] {
        self.players.reduce([]) { (res: [Track], player) -> [Track] in
            var res = res
            res.append(contentsOf: player.tracksOwned)
            return res
        }
    }
    
    func unownedTracks() -> [Track] {
        let owned = self.ownedTracks()
        return self.game.board.allTracks().filter({ !owned.contains($0) })
    }
    
    func tracksBuildable() -> [Track] {
        return self.unownedTracks().filter({
            guard $0.length <= self.players[self.player()].traincars else { return false }
            switch $0.color {
            case .unspecified: return $0.length <= self.players[self.player()].hand.maxColorCount().1
            default: return $0.length <= self.players[self.player()].hand.cardsOf($0.color)
            }
        })
    }
    
    func getLegalMoves() -> [TurnAction] {
        var rv: [TurnAction] = [.draw(.unspecified)]
        for track in tracksBuildable() {
            rv.append(.build(track))
        }
        return rv
    }
    
    func player() -> Int {
        return self.turn % self.players.count
    }
    
    func nextPlayer() -> Int {
        return (self.turn + 1) % self.players.count
    }
    
    func previousPlayer() -> Int {
        return (self.turn - 1) % self.players.count
    }
    
    func asResultOfAction(_ action: TurnAction) -> (TurnAction, State) {
        var rv = self
        rv.deck = Deck()
        var rva: TurnAction
        switch action {
        case .draw(var color):
            if color == .unspecified { color = rv.deck.draw() }
            _ = rv.players[rv.player()].hand.addCard(color)
            rva = .draw(color)
        case .build(let track):
            rva = .build(track)
            guard track.length <= rv.players[rv.player()].traincars else { fatalError() }
            rv.players[rv.player()].traincars -= track.length
            
            // Set last round if traincars falls beelow cutoff
            if rv.players[rv.player()].traincars <= self.game.rules.traincarCutoff { rv.lastPlayer = rv.previousPlayer() }
            
            switch track.color {
            case .unspecified:
                let color = rv.players[rv.player()].hand.maxColorCount().0
                guard rv.players[rv.player()].hand.playCards(color, count: track.length) else {
                    print(track)
                    fatalError()
                }
            default:
                guard rv.players[rv.player()].hand.playCards(track.color, count: track.length) else {
                    print(track)
                    fatalError()
                }
            }
            rv.players[rv.player()].tracksOwned.append(track)
        }
        
        rv.turn += 1
        return (rva, rv)
    }
    
    func calculateWinner() -> Int {
        var points: [Int] = Array(repeating: 0, count: self.players.count)
        for (k, p) in self.players.enumerated() {
            points[k] += p.tracksOwned.reduce(0, { $0 + $1.points()! })
        }
        return points.firstIndex(of: points.max()!)!
    }
}

