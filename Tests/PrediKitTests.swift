//
//  PrediKitTests.swift
//  PrediKitTests
//
//  Copyright © 2016 TheKrakenDev. All rights reserved.
//

import XCTest
@testable import PrediKit

class PrediKitTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testStringIncluders() {
        let theKrakensTitle = "The Almighty Kraken"
        let predicate = NSPredicate(Kraken.self) { include in
            include.string(.title).equals(theKrakensTitle)
        }
        let expectedPredicate = NSPredicate(format: "title != nil && title == %@", theKrakensTitle)
        XCTAssert(predicate.predicateFormat == expectedPredicate.predicateFormat)
    }
}

//MARK: Test Classes
class Kraken: NSObject {
    var title: String?
    var birthdate: NSDate?
    var isAwesome: Bool!
}

class Cerberus: NSObject {
    var isHungry: Bool?
}