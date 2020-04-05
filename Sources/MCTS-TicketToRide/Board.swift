//
//  Board.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/31/20.
//

import Foundation
import SwiftyJSON
import PathKit

class Board: CustomStringConvertible {
    struct MatrixEntry {
        var length: Int
        var colors: [Color]
    }
    
    private(set) var cities: [City] = []
    private var matrix: [[MatrixEntry?]] = []
    
    var description: String { return "\(matrix)" }
    
    convenience init(fromFile path: Path) throws {
        try self.init(fromJSON: JSON(data: try path.read()))
    }
    
    init(fromJSON json: JSON) throws {
        for (_, subJson):(String, JSON) in json {
            var names: [String] = []
            for name in subJson["endpoints"] {
                let name = name.1.string!
                names.append(name)
                switch cities.filter({ $0.name == name }).count {
                case 0:
                    let city = City(name)
                    cities.append(city)
                    matrix.append(Array(repeating: nil, count: cities.count))
                    for i in 0..<matrix.count {
                        matrix[i].append(nil)
                    }
                case 1: break;
                default: throw TTRError.invalidJSON
                }
            }
            
            guard   let colorName = subJson["color"].string,
                    let color = Color.colorForName(colorName),
                    let length = subJson["length"].int
                    else {
                        throw TTRError.invalidJSON
            }
            
            try insertTrack(cities: names.map({cityWithName($0)!.1}), length: length, color: color)
        }
    }
    
    private func insertTrack(cities input: [City], length: Int, color: Color) throws {
        print("Inserting Track: \(input), \(length), \(color)")
        let indicies = input.map({Int(cities.firstIndex(of: $0)!)})
        if matrix[indicies[0]][indicies[1]] == nil {
            matrix[indicies[0]][indicies[1]] = MatrixEntry(length: length, colors: [color])
            guard matrix[indicies[1]][indicies[0]] == nil else {
                throw TTRError.incosistentAdjacencyMatrix
            }
        } else {
            guard matrix[indicies[0]][indicies[1]]!.length == length else {
                throw TTRError.invalidTrackLength
            }
            matrix[indicies[0]][indicies[1]]!.colors.append(color)
        }
        
        matrix[indicies[1]][indicies[0]] = matrix[indicies[0]][indicies[1]]
    }
    
    
    private func cityWithName(_ name: String) -> (Int, City)? {
        let index = self.cities.firstIndex(of: City(name))
        if index != nil {
            return (Int(index!), self.cities[index!])
        }
        return nil
    }
    

    func tracks() -> [Track] {
        var rv: [Track] = []
        for (i, city) in cities.enumerated() {
            for (k, entry) in matrix[i].enumerated() {
                if entry != nil {
                    for color in entry!.colors {
                        rv.append(Track(endpoints: [city, cities[k]], color: color, length: entry!.length))
                    }
                }
            }
        }
        return rv
    }

//    func adjacentTracks(_ city: City) -> [Track]? {
//        guard let row = matrix[city] else {
//            return nil
//        }
//        for x in row where x != nil {
//            print("\(x!)")
//        }
//    }
//
    func areAdjacent(_ a: City, _ b: City) -> Bool? {
        guard   let A = cities.firstIndex(of: a),
                let B = cities.firstIndex(of: b) else {
            return nil
        }
        
        
        
        return nil
    }
}

class City: CustomStringConvertible, Equatable, Hashable {
    private(set) var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        self.name.hash(into: &hasher)
    }
    
    var description: String {
        return "<City: \(self.name)>"
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.name == rhs.name
    }
}

struct Track: CustomStringConvertible {
    private(set) var endpoints: [City]
    private(set) var color: Color
    private(set) var length: Int
    
    var description: String {
        return "<\(length) \(color) from \(endpoints[0].name) to \(endpoints[1].name)>"
    }
}
