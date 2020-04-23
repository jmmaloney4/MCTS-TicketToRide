import ArgumentParser
import PathKit
import Dispatch
import Foundation

struct MCTS: ParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "MCTS",

        // Commands can define a version for automatic '--version' support.
        // version: "0.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [])
        
        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        // defaultSubcommand: Add.self)
    
    @Argument(help: "Path to map file")
    var path: String
    
    @Argument(help: "Traincars")
    var traincars: Int
    
    @Argument(help: "Games")
    var games: Int
    
    @Argument(help: "Players")
    var players: String
    
    @Argument(help: "MCTS Explore")
    var explore: Double
    
    @Argument(help: "MCTS Iterations")
    var iters: [Int]

    func run() throws {
        let board = try Board(fromFile: Path(path))
        // print(board.allTracks().map({ $0.description }).joined(separator: "\n"))
        // print(board.allTracks().count)
        
        // print(board.allTracks().reduce(0, { return $0 + $1.length }))
        
        let rules = Rules(initialHandCount: 4, initialTraincarCount: traincars, traincarCutoff: 3)
        
        var p: [PlayerType] = []
        var mcts_count: Int = 0
        players.forEach {
            switch $0 {
            case "m": p.append(.mcts(iters[mcts_count], (explore / Double(players.count)) )); mcts_count += 1
            case "r": p.append(.random)
            case "b": p.append(.big)
            default: fatalError()
            }
        }
        
        var times: [TimeInterval] = []
        var wins: [Int] = Array(repeating: 0, count: p.count)
        for _ in 0..<games {
            let start = Date()
            let game = try Game(board: board, deck: Deck(), rules: rules, players: p)
            let w = try! game.start()
            times.append(Date().timeIntervalSince(start))
            wins[w] += 1
        }
        
        print("------- RUN DATA ------------------")
        print("Players:", p)
        print("Wins:", wins)
        print("Total Games:", games)
        print("Times:", times)
    }
}

MCTS.main()
