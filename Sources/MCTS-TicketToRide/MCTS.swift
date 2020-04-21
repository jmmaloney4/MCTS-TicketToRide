//
//  MCTSTree.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/18/20.
//

import Foundation
import Squall
import Dispatch
import Concurrency

func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}

class MCTSAIPlayerInterface: Player {
    var tree: MCTSTree
    var player: Int
    private var interfaceTimer: Date = Date()
    
    init(state: State, player: Int) {
        self.tree = MCTSTree(state, forPlayer: player)
        self.player = player
    }
    
    func takeTurn(game: Game) throws -> TurnAction {
        let latch = CountDownLatch(count: Rules.mctsIterations)
        for k in 0..<Rules.mctsIterations {
            interfaceTimer = Date()
            DispatchQueue.global(qos: .default).async {
                var rng = makeRNG()
                synchronized(self) {
                    if abs(self.interfaceTimer.timeIntervalSinceNow) > 1.0 {
                        self.interfaceTimer = Date()
                        print(k)
                    }
                }
                
                try! self.tree.runSimulation(rng: &rng)
                latch.countDown()
            }
        }
        latch.await()
        return self.tree.pickMove()
    }
    
    func update(game: Game, player: Int, action: TurnAction) throws {
        try self.tree.updateRoot(action)
        guard self.tree.root.state == game.state else { fatalError() }
    }
}

class MCTSTree {
    private(set) var root: MCTSNode
    private(set) var player: Int
    
    init(_ state: State, forPlayer player: Int) {
        self.root = MCTSNode(withState: state)
        self.player = player
    }
    
    func runSimulation<G: RandomNumberGenerator>(rng: inout G) throws {
        _ = try self.root.simulate(rng: &rng, player: self.player)
    }
    
    func pickMove() -> TurnAction {
        let values = self.root.children.values.filter({ $0.countVisited.value > 0 }).map({ Double($0.countWon.value) / Double($0.countVisited.value) })
        let index: Int = values.firstIndex(of: values.max()!)!
        return Array(self.root.children.keys)[index]
    }
    
    func updateRoot(_ action: TurnAction) throws {
        guard action != .draw(.unspecified) else { fatalError() }
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
    
    fileprivate(set) var countVisited: AtomicInt = AtomicInt(0)
    fileprivate(set) var countWon: AtomicInt = AtomicInt(0)
    
    init(withState state: State) {
        self.state = state
    }
    
    init(asResultOf action: TurnAction, parent: MCTSNode) throws {
        var action = action
        if parent.children[action] != nil { fatalError(TTRError.childAlreadyExists.localizedDescription) }
        (action, self.state) = parent.state.asResultOfAction(action)
        parent.children[action] = self
    }
    
    // https://dke.maastrichtuniversity.nl/m.winands/documents/Encyclopedia_MCTS.pdf
    func computeUCT() -> [TurnAction:Double] {
        var rv: [TurnAction:Double] = [:]
        synchronized(self) {
            let moves = state.getLegalMoves()
            for move in moves {
                var expected: Double
                var explore: Double
                var stats: (won: Int, visited: Int)?
                switch move {
                case .draw:
                    stats = self.children
                        .filter({ switch $0.key { case .draw: return true; default: return false; } })
                        .reduce((0, 0), { return ($0.0 + $1.value.countWon.value, $0.1 + $1.value.countVisited.value) })
                default:
                    if let child = self.children[move] {
                        stats = (child.countWon.value, child.countVisited.value)
                    }
                }
                
                if stats != nil, stats!.visited > 0 {
                    expected = Double(stats!.0) / Double(stats!.1)
                    explore = sqrt(log(Double(self.countVisited.value + 1)) / Double(stats!.1))
                } else {
                    expected = sqrt(2)
                    explore = 1
                }
                
                let uct = expected + (Rules.uctExplorationConstant * explore)
                if uct.isNaN { fatalError() }
                rv[move] = uct
            }
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
        return rv
    }
    
    func simulate<G: RandomNumberGenerator>(rng: inout G, player: Int) throws -> Int {
        let action = maxUCT()
        var winner: Int
        
        var child: MCTSNode!
        var exit: AtomicBool = AtomicBool(false)
        try synchronized(self) {
            let exantChild = self.children[action]
            if exantChild != nil {
                child = exantChild!
            } else {
                child = try MCTSNode(asResultOf: action, parent: self)
                exit.getAndSet(true)
            }
        }
        
        if !exit.value {
            winner = try child.simulate(rng: &rng, player: player)
        } else {
            var state: State = child.state
            while !state.gameOver {
                let moves = state.getLegalMoves()
                let move = moves.randomElement(using: &rng)!
                (_, state) = state.asResultOfAction(move)
            }
            winner = state.calculateWinner()
            
            child.countVisited.increment()
            if winner == player { child.countWon.increment() }
        }
        
        self.countVisited.increment()
        if winner == player { self.countWon.increment() }
        
        return winner
    }
}

class RandomAIPlayerInterface: Player {
    var player: Int
    var rng = makeRNG()
    
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

class BigTrackAIPlayerInterface: Player {
    var player: Int
    var rng = makeRNG()
    
    init(state: State, player: Int) {
        self.player = player
    }
    
    func takeTurn(game: Game) throws -> TurnAction {
        let tracks = game.state.unownedTracks()
        let max = tracks.map({ $0.length }).max()!
        let big = tracks[tracks.firstIndex(where: { $0.length == max })!]
        let moves = game.state.getLegalMoves()
        if moves.contains(.build(big)) {
            return .build(big)
        } else {
            return .draw(.unspecified)
        }
    }
    
    func update(game: Game, player: Int, action: TurnAction) {
        
    }
}
