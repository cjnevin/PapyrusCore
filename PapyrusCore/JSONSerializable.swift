//
//  JSONSerializable.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 3/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public typealias JSON = [String: AnyObject]
public protocol JSONSerializable {
    static func object(from json: JSON) -> Self?
    func toJSON() -> JSON
}

internal enum JSONConfigKey: String {
    case allTilesUsedBonus
    case maximumWordLength
    case blank
    case vowels
    case letters
    case letterPoints
    case letterMultipliers
    case wordMultipliers
    
    func `in`<T>(_ json: JSON) -> T? {
        return json[rawValue] as? T
    }
}

internal enum JSONKey: String {
    case word
    case x
    case y
    case horizontal
    case blank
    case intersections
    case score
    case rack
    case solves
    case letter
    case difficulty
    case bag
    case players
    case playerIndex
    case config
    case serial
    case lastMove
    
    func `in`<T>(_ json: JSON) -> T? {
        return json[rawValue] as? T
    }
}

internal func json(from: [JSONConfigKey: AnyObject]) -> JSON {
    return from.mapTuple({ ($0.rawValue, $1) })
}

internal func json(from: [JSONKey: AnyObject]) -> JSON {
    return from.mapTuple({ ($0.rawValue, $1) })
}

internal func readJSON(from file: URL) -> JSON? {
    guard let data = try? Data(contentsOf: file),
        optionalJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON,
        json = optionalJson else {
            return nil
    }
    return json
}

internal func writeJSON(_ json: JSON, to file: URL) -> Bool {
    do {
        try JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)).write(to: file)
        return true
    } catch {
        return false
    }
}
