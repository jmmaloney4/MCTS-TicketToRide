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

class MCTSTree {
    private(set) var root: MCTSNode
    
    init(_ state: State) {
        self.root = MCTSNode(withState: state)
    }
}

class MCTSNode {
    private(set) var children: [TurnAction:MCTSNode] = [:]
    private(set) var state: State
    
    private(set) var countVisited: Int = 0
    private(set) var countWon: Int = 0
    
    init(withState state: State) {
        self.state = state
    }
    
    init(asResultOf action: TurnAction, parent: MCTSNode) throws {
        if parent.children[action] != nil { throw TTRError.childAlreadyExists }
        guard let state = parent.state.asResultOfAction(action) else {
            throw TTRError.invalidAction
        }
        self.state = state
        parent.children[action] = self
    }
    
    // https://dke.maastrichtuniversity.nl/m.winands/documents/Encyclopedia_MCTS.pdf
    func computeUCT() -> [TurnAction:Double] {
        self.countVisited += 1
        
        var rv: [TurnAction:Double] = [:]
        let moves = state.getLegalMoves()
        print(moves)
        let expected = Double(self.countWon) / Double(self.countVisited)
        for move in moves {
            var explore: Double
            if let child = self.children[move] {
                explore = sqrt(log(Double(self.countVisited)) / Double(child.countVisited))
            } else {
                explore = 1
            }
            let uct = expected + Rules.uctExplorationConstant * explore
            rv[move] = uct
        }
        return rv
    }
    
    func maxUCT() -> TurnAction {
        let uct = computeUCT()
        guard let max = uct.values.max() else { fatalError() }
        return uct.enumerated().first(where: { element -> Bool in element.element.value == max })!.element.key
    }
    
    func uct() throws -> MCTSNode {
        let action = maxUCT()
        if self.children[action] != nil {
            return try self.children[action]!.uct()
        }
        return try MCTSNode(asResultOf: action, parent: self)
    }
}

struct State {
    private(set) var game: Game
    private(set) var deck: Deck
    private(set) var players: [PlayerState] = []
    private(set) var turn: Int = 0
    
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
    
    func asResultOfAction(_ action: TurnAction) -> State? {
        var rv = self
        switch action {
        case .draw:
            _ = rv.players[turn].hand.addCard(rv.deck.draw())
        case .build(let track):
            switch track.color {
            case .unspecified:
                guard rv.players[turn].hand.playCards(count: track.length) != nil else {
                    return nil
                }
            default:
                guard rv.players[turn].hand.playCards(track.color, count: track.length) != nil else {
                    return nil
                }
            }
        }
        
        if self.turn < players.count - 1 {
            rv.turn += 1
        } else {
            rv.turn = 0
        }
        
        return rv
    }
}

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
        
        for _ in 0..<players.count {
            self.trees.append(MCTSTree(self.state))
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

protocol Player {
    func takeTurn(tree: MCTSTree, game: Game) throws -> TurnAction
}

class MCTSAIPlayerInterface: Player {
    func takeTurn(tree: MCTSTree, game: Game) throws -> TurnAction {
        return tree.root.maxUCT()
    }
}
