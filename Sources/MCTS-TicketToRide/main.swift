import ArgumentParser
import PathKit
import Dispatch

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
    
    @Argument(help: "MCTS Iterations")
    var iterations: Int
    
    @Argument(help: "Players")
    var players: String
    
    @Argument(help: "Games")
    var games: Int

    func run() throws {
        let board = try Board(fromFile: Path(path))
        print(board.allTracks().map({ $0.description }).joined(separator: "\n"))
        print(board.allTracks().count)
        
        var a = AtomicInt()
        print(a.incrementAndGet())
        DispatchQueue.global().async {
            print(a.incrementAndGet())
        }
        DispatchQueue.global().async {
            print(a.incrementAndGet())
        }
        DispatchQueue.global().async {
            print(a.incrementAndGet())
        }
        DispatchQueue.global().async {
            print(a.incrementAndGet())
        }
        
        
        Rules.initialTraincarCount = traincars
        Rules.mctsIterations = iterations
        
        var p: [PlayerType] = []
        players.forEach {
            switch $0 {
            case "m": p.append(.mcts)
            case "r": p.append(.random)
            case "b": p.append(.big)
            default: fatalError()
            }
        }
        
        var wins: [Int] = Array(repeating: 0, count: p.count)
        for _ in 0..<games {
            let game = try Game(board: board, deck: Deck(), players: p)
            let w = try! game.start()
            wins[w] += 1
        }
        
        print(p)
        print(wins)
        
    }
}

MCTS.main()
