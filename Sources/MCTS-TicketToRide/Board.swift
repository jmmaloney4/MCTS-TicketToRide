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
    struct MatrixEntry: Equatable {
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
                    for i in 0..<(matrix.count-1) {
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
         
            try ensureMatrixConsistency()
            try insertTrack(cities: names.map({cityWithName($0)!.1}), length: length, color: color)
        }
        try ensureMatrixConsistency()
    }
    
    private func ensureMatrixConsistency() throws {
        for row in matrix {
            guard row.count == cities.count else {
                print("Row: \(row.count) != \(cities.count)")
                throw TTRError.incosistentAdjacencyMatrix
            }
        }
        
        for i in 0..<cities.count {
            for k in 0..<cities.count {
                guard matrix[i][k] == matrix[k][i] else {
                    throw TTRError.incosistentAdjacencyMatrix
                }
            }
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
    

    func allTracks() -> [Track] {
        var rv: [Track] = []
        for (i, city) in cities.enumerated() {
            for (k, entry) in matrix[i].enumerated() {
                if entry != nil {
                    for color in entry!.colors {
                        rv.append(Track(city, cities[k], color: color, length: entry!.length))
                    }
                }
            }
        }
        return rv
    }

    func adjacentTracks(_ city: City) -> [Track]? {
        guard let index = cities.firstIndex(of: city) else {
            return nil
        }
        var rv: [Track] = []
        for (i, entry) in matrix[index].enumerated() {
            if entry != nil {
                for color in entry!.colors {
                    rv.append(Track(city, cities[i], color: color, length: entry!.length))
                }
            }
        }
        
        return rv
    }

    func areAdjacent(_ a: City, _ b: City) -> Bool? {
        guard   let A = cities.firstIndex(of: a),
                let B = cities.firstIndex(of: b) else {
            return nil
        }
        
        return matrix[Int(A)][Int(B)] != nil
    }
    
    func tracksBetween(_ a: City, _ b: City) -> [Track]? {
        guard   let A = cities.firstIndex(of: a),
                let B = cities.firstIndex(of: b) else {
            return nil
        }
        var rv: [Track] = []
        if matrix[Int(A)][Int(B)] != nil {
            for color in matrix[Int(A)][Int(B)]!.colors {
                rv.append(Track(a, b, color: color, length: matrix[Int(A)][Int(B)]!.length))
            }
        }
        return rv
    }
}

struct City: CustomStringConvertible, Equatable, Hashable {
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

class Track: CustomStringConvertible, Equatable, Hashable {
    private(set) var endpoints: [City]
    private(set) var color: Color
    private(set) var length: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(length)
        hasher.combine(endpoints)
        hasher.combine(color)
    }
    
    init(_ a: City, _ b: City, color: Color, length: Int) {
        self.endpoints = [a,b]
        self.color = color
        self.length = length
    }
    
    var description: String {
        return "<\(length) \(color) from \(endpoints[0].name) to \(endpoints[1].name)>"
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return Set(lhs.endpoints) == Set(rhs.endpoints)
            && lhs.color == rhs.color && lhs.length == rhs.length
    }
}
