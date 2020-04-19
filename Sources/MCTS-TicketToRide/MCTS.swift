//
//  MCTSTree.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/18/20.
//

import Foundation
import Squall

class MCTSTree {
    private(set) var root: MCTSNode
    private(set) var player: Int
    
    init(_ state: State, forPlayer player: Int) {
        self.root = MCTSNode(withState: state)
        self.player = player
    }
    
    func runSimulation(rng: Gust) throws {
        let exit = try self.root.uct()
        
        var state: State = exit.state
        while !state.gameOver {
            let moves = state.getLegalMoves()
            let move = moves[Int(rng.next() / UInt64(UInt32.max)) % moves.count]
            state = state.asResultOfAction(move)
        }
        
        let winner = state.calculateWinner()
        self.update(withWinner: winner)
    }
    
    func update(withWinner winner: Int) {
        var parent: MCTSNode = self.root
        var next: MCTSNode? = self.root.children[self.root.maxUCT()]
        while next != nil {
            parent.countVisited += 1
            if winner == self.player {
                parent.countWon += 1
            }
            parent = next!
            next = next!.children[next!.maxUCT()]
        }
    }
    
    func pickMove() -> TurnAction {
        let values = self.root.children.values.map({ Double($0.countWon) / Double($0.countVisited) })
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
        if parent.children[action] != nil { throw TTRError.childAlreadyExists }
        let state = parent.state.asResultOfAction(action)
        self.state = state
        parent.children[action] = self
    }
    
    // https://dke.maastrichtuniversity.nl/m.winands/documents/Encyclopedia_MCTS.pdf
    func computeUCT() -> [TurnAction:Double] {
        var rv: [TurnAction:Double] = [:]
        let moves = state.getLegalMoves()
        var expected: Double
        if self.countVisited == 0 {
            expected = sqrt(2) // sqrt?
        } else {
            expected = Double(self.countWon) / Double(self.countVisited)
        }
        for move in moves {
            var explore: Double
            if let child = self.children[move], child.countVisited > 0 {
                explore = sqrt(log(Double(self.countVisited + 1)) / Double(child.countVisited))
            } else {
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
        guard self.children[action] === rv else { fatalError() }
        return rv
    }
}
