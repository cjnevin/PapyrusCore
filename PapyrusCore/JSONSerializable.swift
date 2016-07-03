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
