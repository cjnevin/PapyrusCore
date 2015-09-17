//
//  DawgTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 16/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class DawgTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func printNode(node: DawgNode, _ prefix: String) {
        print("\(prefix): \(node)")
        node.edges.forEach({ (key, value) in
            printNode(value, "-\(prefix)")
        })
    }
    
    func testCreateDawg() {
        
        let dawg = Dawg()
        /*let path: String = (NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true).first! as NSString)
            .stringByAppendingPathComponent("dawg.dat")
        print(path)*/
        let bundle = NSBundle(forClass: DawgTests.self)
        let sowpods = bundle.pathForResource("sowpods", ofType: "txt")!
        let lines = try! NSString(contentsOfFile: sowpods, encoding: NSUTF8StringEncoding).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var c = 0
        var last = NSDate().timeIntervalSinceReferenceDate
        
        for line in lines {
            dawg.insert(line)
            c++
            if (c % 1000 == 0) {
                print(line, c, (Double(c) / Double(lines.count)) * 100)
            }
        }
        
        last = NSDate().timeIntervalSinceReferenceDate - last
        print("Imported \(lines.count) in \(last)")
        
        measureBlock { () -> Void in
            dawg.lookup("quincentennial")
            dawg.lookup("zeal")
            dawg.lookup("starter")
        }
        
        //dawg.save(path)
        //print(path)
    }
    
    func testDawg() {
        
        let dawg = Dawg()
        dawg.insert("CAD")
        dawg.insert("CADE")
        dawg.insert("CAR")
        dawg.insert("CARE")
        dawg.insert("CART")
        dawg.insert("CAT")
        dawg.insert("CATE")
        dawg.insert("CATER")
        dawg.insert("CATERS")
        dawg.insert("CATS")
        dawg.insert("CITE")
        
        printNode(dawg.rootNode, "root")
        
        print("---")
        
    }
}
