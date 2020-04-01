//
//  Board.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/31/20.
//

import Foundation
import SwiftyJSON
import PathKit

struct Board {
    private(set) var tracks: [Track]
    
    init(withTracks tracks: [Track]) {
        self.tracks = tracks
    }
    
    init(fromJSONFile path: Path) throws {
        try self.init(withJSON: JSON(data: try path.read()))
    }
    
    init(withJSON: JSON) throws {
        self.tracks = []
        for (_, subJson):(String, JSON) in json {
            guard
                let cityAName = subJson["endpoints"][0].string,
                let cityBName = subJson["endpoints"][1].string,
                let colorName = subJson["color"].string,
                let color = Color.colorForName(colorName),
                let length = subJson["length"].int else {
                throw TTRError.invalidJSON
            }
            
            self.tracks.append(Track(endpoints: [City(cityAName), City(cityBName)], color: color, length: length))
        }
    }
    
    public var json: JSON {
        var array: [[String: Any]] = []
        for track in self.tracks {
            array.append(["endpoints": track.endpoints.map({ "\($0)" }),
                          "color": "\(track.color)",
                          "length": track.length])
        }
        return JSON(array)
    }
}

struct City: CustomStringConvertible, Equatable {
    private(set) var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var description: String {
        return "<City: \(self.name)>"
    }
}

struct Track: CustomStringConvertible {
    private(set) var endpoints: [City]
    private(set) var color: Color
    private(set) var length: Int
    
    var description: String {
        return "<Track from \(endpoints[0].name) to \(endpoints[1].name)>"
    }
}
