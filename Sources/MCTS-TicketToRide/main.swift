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
    
    @Option(name: .shortAndLong, help: "CSV file")
    var out: String

    func run() throws {
        let board = try Board(fromFile: Path(path))
        
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

        let out = Path(self.out)
        try out.write("GAME,WINNER,TIME\n")
        
        var times: [TimeInterval] = []
        var wins: [Int] = Array(repeating: 0, count: p.count)
        for k in 0..<games {
            let start = Date()
            let game = try Game(board: board, deck: Deck(), rules: rules, players: p)
            let w = try! game.start()
            let time = Date().timeIntervalSince(start)
            times.append(time)
            wins[w] += 1
            try [k, w, time].map({ "\($0)" }).joined(separator: ",").appendLineToURL(fileURL: out.url)
        }
        
        print("------- START RUN DATA ------------------")

        print("Players:", p)
        print("Wins:", wins)
        print("Total Games:", games)
        print("Times:", times)
        
        print("------- END RUN DATA ------------------")
    }
}

MCTS.main()

extension String {
   func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.synchronizeFile()
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
