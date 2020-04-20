//
//  MCTSTree.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/18/20.
//

import Foundation
import Squall

class MCTSAIPlayerInterface: Player {
    var tree: MCTSTree
    var player: Int
    
    init(state: State, player: Int) {
        self.tree = MCTSTree(state, forPlayer: player)
        self.player = player
    }
    
    func takeTurn(game: Game) throws -> TurnAction {
        let rng = newGust()
        for k in 0..<Rules.mctsIterations {
            try self.tree.runSimulation(rng: rng)
        }
        return self.tree.pickMove()
    }
    
    func update(game: Game, player: Int, action: TurnAction) throws {
        try self.tree.updateRoot(action)
    }
}

class MCTSTree {
    private(set) var root: MCTSNode
    private(set) var player: Int
    
    init(_ state: State, forPlayer player: Int) {
        self.root = MCTSNode(withState: state)
        self.player = player
    }
    
    func runSimulation(rng: Gust) throws {
        _ = try self.root.simulate(rng: rng, player: self.player)
    }
    
    func pickMove() -> TurnAction {
        let values = self.root.children.values.filter({ $0.countVisited > 0 }).map({ Double($0.countWon) / Double($0.countVisited) })
        let index: Int = values.firstIndex(of: values.max()!)!
        return Array(self.root.children.keys)[index]
    }
    
    func updateRoot(_ action: TurnAction) throws {
        if let root = self.root.children[action] {
            self.root = root
        } else {
            self.root = try MCTSNode(asResultOf: action, parent: self.root)
        }
    }
}

class MCTSNode {
    private(set) var children: [TurnAction:MCTSNode] = [:]
    private(set) var state: State
    
    fileprivate(set) var countVisited: Int = 0
    fileprivate(set) var countWon: Int = 0
    
    init(withState state: State) {
        self.state = state
    }
    
    init(asResultOf action: TurnAction, parent: MCTSNode) throws {
        var action = action
        if parent.children[action] != nil { throw TTRError.childAlreadyExists }
        (action, self.state) = parent.state.asResultOfAction(action)
        parent.children[action] = self
    }
    
    // https://dke.maastrichtuniversity.nl/m.winands/documents/Encyclopedia_MCTS.pdf
    func computeUCT() -> [TurnAction:Double] {
        var rv: [TurnAction:Double] = [:]
        let moves = state.getLegalMoves()
        for move in moves {
            var expected: Double
            var explore: Double
            var stats: (won: Int, visited: Int)?
            switch move {
            case .draw:
                stats = self.children
                    .filter({ switch $0.key { case .draw: return true; default: return false; } })
                    .reduce((0, 0), { return ($0.0 + $1.value.countWon, $0.1 + $1.value.countVisited) })
            default:
                if let child = self.children[move] {
                    stats = (child.countWon, child.countVisited)
                }
            }
            
            if stats != nil, stats!.visited > 0 {
                expected = Double(stats!.0) / Double(stats!.1)
                explore = sqrt(log(Double(self.countVisited + 1)) / Double(stats!.1))
            } else {
                expected = sqrt(2)
                explore = 1
            }
            
            let uct = expected + (Rules.uctExplorationConstant * explore)
            if uct.isNaN { fatalError() }
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
        let rv = try MCTSNode(asResultOf: action, parent: self)
        // guard self.children[action] === rv else { fatalError() }
        return rv
    }
    
    func simulate(rng: Gust, player: Int) throws -> Int {
        let action = maxUCT()
        var winner: Int
        if self.children[action] != nil {
            winner = try self.children[action]!.simulate(rng: rng, player: player)
        } else {
            let child = try MCTSNode(asResultOf: action, parent: self)
            var state: State = child.state
            while !state.gameOver {
                let moves = state.getLegalMoves()
                let move = moves[Int(rng.next() / UInt64(UInt32.max)) % moves.count]
                (_, state) = state.asResultOfAction(move)
            }
            winner = state.calculateWinner()
            
            child.countVisited += 1
            if winner == player { child.countWon += 1 }
        }
        
        self.countVisited += 1
        if winner == player { self.countWon += 1 }
        
        return winner
    }
}


class RandomAIPlayerInterface: Player {
    var player: Int
    var rng: Gust = newGust()
    
    init(state: State, player: Int) {
        self.player = player
    }
    
    func takeTurn(game: Game) throws -> TurnAction {
        let moves = game.state.getLegalMoves()
        return moves[Int(rng.next(upperBound: UInt(moves.count)))]
    }
    
    func update(game: Game, player: Int, action: TurnAction) {
        
    }
    
}
