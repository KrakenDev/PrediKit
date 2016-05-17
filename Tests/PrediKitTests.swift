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
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle)
        }
        let expectedPredicate = NSPredicate(format: "title == %@", theKrakensTitle)
        XCTAssert(predicate.predicateFormat == expectedPredicate.predicateFormat)
    }
    
    func testCombinationsWithoutParentheses() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle) ||
            includeIf.string(.title).equals(theKrakensTitle) ||
            includeIf.string(.title).equals(theKrakensTitle) &&
            includeIf.date(.birthdate).equals(rightNow) ||
            includeIf.bool(.isAwesome).isTrue &&
            includeIf.date(.birthdate).equals(rightNow) ||
            includeIf.bool(.isAwesome).isTrue
        }
        let expectedPredicate = NSPredicate(format: "title == '\(theKrakensTitle)' || title == '\(theKrakensTitle)' || title == '\(theKrakensTitle)' && birthdate == %@ || isAwesome == true && birthdate == %@ || isAwesome == true", rightNow, rightNow)
        XCTAssert(predicate.predicateFormat == expectedPredicate.predicateFormat, "expected \(expectedPredicate.predicateFormat),\ninstead, got \(predicate.predicateFormat)")
    }

    func testCombinationsWithParentheses() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            (includeIf.string(.title).equals(theKrakensTitle) ||
             includeIf.string(.title).equals(theKrakensTitle) ||
             includeIf.string(.title).equals(theKrakensTitle))
            &&
            (includeIf.date(.birthdate).equals(rightNow) ||
             includeIf.bool(.isAwesome).isTrue)
            &&
            (includeIf.date(.birthdate).equals(rightNow) ||
             includeIf.bool(.isAwesome).isTrue)
        }
        let expectedPredicate = NSPredicate(format: "(title == '\(theKrakensTitle)' || title == '\(theKrakensTitle)' || title == '\(theKrakensTitle)') && (birthdate == %@ || isAwesome == true) && (birthdate == %@ || isAwesome == true)", rightNow, rightNow)
        XCTAssert(predicate.predicateFormat == expectedPredicate.predicateFormat, "expected \(expectedPredicate.predicateFormat),\ninstead, got \(predicate.predicateFormat)")
    }
}

//MARK: Test Classes
class Kraken: NSObject {
    var title: String?
    var birthdate: NSDate?
    var isAwesome: Bool?
}

class Cerberus: NSObject {
    var isHungry: Bool?
}