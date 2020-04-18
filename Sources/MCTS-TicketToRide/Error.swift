//
//  Error.swift
//  MCTS-TicketToRide
//
//  Created by Jack Maloney on 3/31/20.
//

import Foundation

public enum TTRError: Error {
    case invalidJSON
    case fileError(path: String)
    case jsonToStringError
    case socketError
    case dataError
    case incosistentAdjacencyMatrix
    case invalidTrackLength
    case invalidAction
    case childAlreadyExists
}
