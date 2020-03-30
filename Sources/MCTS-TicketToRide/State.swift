//
//  State.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/26/20.
//

import Foundation

public enum Color: Int, CustomStringConvertible {
    case red = 0
    case blue = 1
    case black = 2
    case white = 3
    case orange = 4
    case yellow = 5
    case pink = 6
    case green = 7
    case unspecified = -1 // Used only for tracks
    case locomotive = 8 // Used for cards, not tracks

    static func colorForIndex(_ index: Int) -> Color? {
        switch index {
        case Color.red.rawValue: return .red
        case Color.blue.rawValue: return .blue
        case Color.black.rawValue: return .black
        case Color.white.rawValue: return .white
        case Color.orange.rawValue: return .orange
        case Color.yellow.rawValue: return .yellow
        case Color.pink.rawValue: return .pink
        case Color.green.rawValue: return .green
        case Color.locomotive.rawValue: return .locomotive
        default: return nil
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func colorForName(_ name: String) -> Color? {
        switch name {
        case Color.red.description: return .red
        case Color.blue.description: return .blue
        case Color.black.description: return .black
        case Color.white.description: return .white
        case Color.orange.description: return .orange
        case Color.yellow.description: return .yellow
        case Color.pink.description: return .pink
        case Color.green.description: return .green
        case Color.unspecified.description: return .unspecified
        case Color.locomotive.description: return .locomotive
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .black: return "Black"
        case .white: return "White"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .pink: return "Pink"
        case .green: return "Green"
        case .unspecified: return "Unspecified"
        case .locomotive: return "Locomotive"
        }
    }

    public var key: String {
        self.description
    }

    public static func allCards() -> [Color] {
        [.red, .blue, .black, .white, .orange, .yellow, .pink, .green, .locomotive]
    }
}

public enum MCTSTTRError: Error {
    case invalidJSON
    case fileError(path: String)
    case jsonToStringError
    case socketError
    case dataError
}

struct Deck {
    var cards: [Color] = []

    init(colors: [Color] = Color.allCards(), cardsPerColor: Int = 8) {
        for color in colors {
            for _ in 0 ..< cardsPerColor {
                cards.append(color)
            }
        }
    }
}

struct City {
    private(set) var name: String
}

struct Track {
    private(set) var endpoints: [City]
    private(set) var color: Color
}

struct Hand {
    private var cards: [Color:Int]
}

struct Player {
    private(set) var hand: Hand
    private(set) var traincars: Int
}

struct Board {
    private(set) var tracks:[Track]
}

struct State {
    var deck: Deck = Deck()
    var players: [Player]
}

struct Game {
    
}
