//
//  JSONSerializable.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 3/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

enum JSONKey: String {
    case word = "w"
    case x
    case y
    case horizontal = "h"
    case blank = "b"
    case intersections = "i"
    case score = "s"
    case rack = "r"
    case solves = "o"
    case letter = "l"
    case difficulty = "d"
    case gameType = "t"
    case bag
    case players
    case playerIndex = "index"
    case serial
    case lastMove
    
    func `in`<T>(_ json: JSON) -> T? {
        return json[rawValue] as? T
    }
}

func json(from: [JSONKey: AnyObject]) -> JSON {
    var result = JSON()
    zip(from.keys.map({ $0.rawValue }), from.values).forEach { (key, value) in
        result[key] = value
    }
    return result
}


public typealias JSON = [String: AnyObject]
public protocol JSONSerializable {
    static func object(from json: JSON) -> Self?
    func toJSON() -> JSON
}

func readJSON(from file: URL) -> JSON? {
    guard let data = try? Data(contentsOf: file),
        optionalJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON,
        json = optionalJson else {
            return nil
    }
    return json
}

func writeJSON(_ json: JSON, to file: URL) -> Bool {
    do {
        try JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)).write(to: file)
        return true
    } catch {
        return false
    }
}
