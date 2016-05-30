//
//  PrediKitTests.swift
//  PrediKitTests
//
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import XCTest
@testable import PrediKit

class PrediKitTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testEmptyBuilderBehavior() {
        let predicate = NSPredicate(Kraken.self) { includeIf in
            XCTAssertEqual(includeIf.predicateString, "")
        }
        XCTAssertEqual(predicate, NSPredicate(value: false))
    }
    
    func testCommonIncluders() {
        let legendaryArray = ["Kraken", "Kraken", "Kraken", "Kraken", "Cthulhu", "Voldemort", "Ember", "Umber", "Voldemort"]
        let legendarySet: Set<String> = ["Kraken", "Kraken", "Kraken", "Kraken", "Cthulhu", "Voldemort", "Ember", "Umber", "Voldemort"]
        let foundationArray: NSArray = ["Kraken", "Kraken", "Kraken", "Kraken", "Cthulhu", "Voldemort", "Ember", "Umber", "Voldemort"]
        
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.SELF.equalsNil
            XCTAssertEqual(includeIf.predicateString, "SELF == nil")
            includeIf.string(.title).equalsNil
            XCTAssertEqual(includeIf.predicateString, "title == nil")
            !includeIf.string(.title).equalsNil
            XCTAssertEqual(includeIf.predicateString, "!(title == nil)")
            includeIf.SELF.matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "SELF IN %@")
            includeIf.SELF.matchesAnyValueIn(legendarySet)
            XCTAssertEqual(includeIf.predicateString, "SELF IN %@")
            includeIf.member(.bestElfFriend, ofType: Elf.self).matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "bestElfFriend IN %@")
            includeIf.string(.title).matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "title IN %@")
            includeIf.string(.title).matchesAnyValueIn(foundationArray)
            XCTAssertEqual(includeIf.predicateString, "title IN %@")
        }
    }
    
    func testStringIncluders() {
        let theKrakensTitle = "The Almighty Kraken"
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).isEmpty
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title == \"\"", theKrakensTitle).predicateFormat)
            includeIf.string(.title).beginsWith(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).endsWith(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).contains(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).matches(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).equals(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title == %@", theKrakensTitle).predicateFormat)
        }
    }
    
    func testStringIncludersWithOptions() {
        let theKrakensTitle = "The Almighty Kraken"
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).beginsWith(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).endsWith(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).contains(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).matches(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[c] %@", theKrakensTitle).predicateFormat)

            includeIf.string(.title).beginsWith(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).endsWith(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).contains(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).matches(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[d] %@", theKrakensTitle).predicateFormat)

            includeIf.string(.title).beginsWith(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).endsWith(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).contains(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.title).matches(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[cd] %@", theKrakensTitle).predicateFormat)
        }
    }
    
    func testNumberIncluders() {
        let testAge = 5
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.number(.age).doesNotEqual(testAge)
            XCTAssertEqual(includeIf.predicateString, "age != %@")
            includeIf.number(.age).equals(testAge)
            XCTAssertEqual(includeIf.predicateString, "age == %@")
            includeIf.number(.age).isGreaterThan(testAge)
            XCTAssertEqual(includeIf.predicateString, "age > %@")
            includeIf.number(.age).isGreaterThanOrEqualTo(testAge)
            XCTAssertEqual(includeIf.predicateString, "age >= %@")
            includeIf.number(.age).isLessThan(testAge)
            XCTAssertEqual(includeIf.predicateString, "age < %@")
            includeIf.number(.age).isLessThanOrEqualTo(testAge)
            XCTAssertEqual(includeIf.predicateString, "age <= %@")
        }
    }
    
    func testDateIncluders() {
        let rightNow = NSDate()
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.date(.birthdate).equals(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate == %@")
            includeIf.date(.birthdate).isEarlierThan(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate < %@")
            includeIf.date(.birthdate).isEarlierThanOrOn(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate <= %@")
            includeIf.date(.birthdate).isLaterThan(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate > %@")
            includeIf.date(.birthdate).isLaterThanOrOn(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate >= %@")
        }
    }
    
    func testBoolIncluders() {
        let truePredicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.bool(.isAwesome).isTrue
        }
        XCTAssertEqual(truePredicate.predicateFormat, NSPredicate(format: "isAwesome == true").predicateFormat)

        let falsePredicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.bool(.isAwesome).isFalse
        }
        XCTAssertEqual(falsePredicate.predicateFormat, NSPredicate(format: "isAwesome == false").predicateFormat)
    }
    
    func testCollectionIncluders() {
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).isEmpty
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "friends.@count == 0").predicateFormat)
        }
    }
    
    func testSubqueryIncluders() {
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).subquery(Cerberus.self) { includeIf in
                includeIf.bool(.isHungry).isTrue &&
                includeIf.bool(.isAwesome).isTrue
                return .IncludeIfMatched(.Amount(.Equals(0)))
            }
        }
        XCTAssertEqual(predicate.predicateFormat, NSPredicate(format: "SUBQUERY(friends, $CerberusItem, $CerberusItem.isHungry == true && $CerberusItem.isAwesome == true).@count == 0").predicateFormat)
    }
    
    func testSubqueryReturnTypeStrings() {
        let match = MatchType.IncludeIfMatched
        let amount = MatchType.FunctionType.Amount
        XCTAssertEqual(match(amount(.Equals(0))).collectionQuery, "@count == 0")
        XCTAssertEqual(match(amount(.IsLessThan(0))).collectionQuery, "@count < 0")
        XCTAssertEqual(match(amount(.IsLessThanOrEqualTo(0))).collectionQuery, "@count <= 0")
        XCTAssertEqual(match(amount(.IsGreaterThan(0))).collectionQuery, "@count > 0")
        XCTAssertEqual(match(amount(.IsGreaterThanOrEqualTo(0))).collectionQuery, "@count >= 0")

        let min = MatchType.FunctionType.MinValue
        XCTAssertEqual(match(min(.Equals(0))).collectionQuery, "@min == 0")
        XCTAssertEqual(match(min(.IsLessThan(0))).collectionQuery, "@min < 0")
        XCTAssertEqual(match(min(.IsLessThanOrEqualTo(0))).collectionQuery, "@min <= 0")
        XCTAssertEqual(match(min(.IsGreaterThan(0))).collectionQuery, "@min > 0")
        XCTAssertEqual(match(min(.IsGreaterThanOrEqualTo(0))).collectionQuery, "@min >= 0")

        let max = MatchType.FunctionType.MaxValue
        XCTAssertEqual(match(max(.Equals(0))).collectionQuery, "@max == 0")
        XCTAssertEqual(match(max(.IsLessThan(0))).collectionQuery, "@max < 0")
        XCTAssertEqual(match(max(.IsLessThanOrEqualTo(0))).collectionQuery, "@max <= 0")
        XCTAssertEqual(match(max(.IsGreaterThan(0))).collectionQuery, "@max > 0")
        XCTAssertEqual(match(max(.IsGreaterThanOrEqualTo(0))).collectionQuery, "@max >= 0")

        let avg = MatchType.FunctionType.AverageValue
        XCTAssertEqual(match(avg(.Equals(0))).collectionQuery, "@avg == 0")
        XCTAssertEqual(match(avg(.IsLessThan(0))).collectionQuery, "@avg < 0")
        XCTAssertEqual(match(avg(.IsLessThanOrEqualTo(0))).collectionQuery, "@avg <= 0")
        XCTAssertEqual(match(avg(.IsGreaterThan(0))).collectionQuery, "@avg > 0")
        XCTAssertEqual(match(avg(.IsGreaterThanOrEqualTo(0))).collectionQuery, "@avg >= 0")
    }
    
    func testMemberIncluders() {
        let elf = Elf()
        let elfName = "Aragorn"
        let enemyBirthdate = NSDate()
        let predicate = NSPredicate(Kraken.self) { includeIf in
            let bestElfFriend = includeIf.member(.bestElfFriend, ofType: Elf.self)
            let bestElfFriendsMortalEnemy = bestElfFriend.member(.birthdate, ofType: Cerberus.self)

            !bestElfFriend.equalsNil &&
            bestElfFriend.equals(elf) &&
            bestElfFriendsMortalEnemy.date(.birthdate).equals(enemyBirthdate) &&
            bestElfFriend.string(.title).equals(elfName)
        }
        XCTAssertEqual(predicate.predicateFormat, NSPredicate(format: "!(bestElfFriend == nil) && bestElfFriend == %@ && bestElfFriend.birthdate.birthdate == %@ && bestElfFriend.title == %@", elf, enemyBirthdate, elfName).predicateFormat)
    }
    
    func testSimpleANDIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle) &&
            includeIf.date(.birthdate).isEarlierThan(rightNow)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ && birthdate < %@", theKrakensTitle, rightNow)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testChainedANDIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        let isAwesome = true
        let age = 5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle) &&
            includeIf.date(.birthdate).isEarlierThan(rightNow) &&
            includeIf.bool(.isAwesome).isTrue &&
            includeIf.number(.age).equals(age)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ && birthdate < %@ && isAwesome == %@ && age == \(age)", theKrakensTitle, rightNow, isAwesome)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testSimpleORIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle) ||
            includeIf.date(.birthdate).isEarlierThan(rightNow)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ || birthdate < %@", theKrakensTitle, rightNow)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testChainedORIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = NSDate()
        let isAwesome = true
        let age = 5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.title).equals(theKrakensTitle) ||
            includeIf.date(.birthdate).isEarlierThan(rightNow) ||
            includeIf.bool(.isAwesome).isTrue ||
            includeIf.number(.age).equals(age)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ || birthdate < %@ || isAwesome == %@ || age == \(age)", theKrakensTitle, rightNow, isAwesome)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testComplexIncluderCombinationsWithoutParentheses() {
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
        let expectedPredicate = NSPredicate(format: "title == %@ || title == %@ || title == %@ && birthdate == %@ || isAwesome == true && birthdate == %@ || isAwesome == true", theKrakensTitle, theKrakensTitle, theKrakensTitle, rightNow, rightNow)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }

    func testComplexIncluderCombinationsWithParentheses() {
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
        let expectedPredicate = NSPredicate(format: "(title == %@ || title == %@ || title == %@) && (birthdate == %@ || isAwesome == true) && (birthdate == %@ || isAwesome == true)", theKrakensTitle, theKrakensTitle, theKrakensTitle, rightNow, rightNow)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }

    func testComplexIncluderCombinationsWithSubquery() {
        let theKrakensTitle = "The Almighty Kraken"
        let theElfTitle = "The Lowly Elf"
        let rightNow = NSDate()
        let age = 5.5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).subquery(Cerberus.self) { includeIf in
                let isTheKraken = includeIf.string(.title).equals(theKrakensTitle)
                let isBirthedToday = includeIf.date(.birthdate).equals(rightNow)
                let isHungry = includeIf.bool(.isHungry).isTrue
                let isOlderThan5AndAHalf = includeIf.number(.age).isGreaterThan(age)
                let hasElfSubordinates = includeIf.collection(.subordinates).subquery(Elf.self) { includeIf in
                    includeIf.string(.title).equals(theElfTitle)
                    return .IncludeIfMatched(.Amount(.IsGreaterThan(0)))
                }
                let hasCerberusSubordinates = includeIf.collection(.subordinates).subquery(Cerberus.self) { includeIf in
                    let age = includeIf.number(.age).equals(age)
                    let birthdate = includeIf.date(.birthdate).equals(rightNow)
                    
                    birthdate || age
                    return .IncludeIfMatched(.Amount(.IsGreaterThan(0)))
                }
                
                isTheKraken || isOlderThan5AndAHalf || isHungry || (isBirthedToday && !hasElfSubordinates && hasCerberusSubordinates)
                
                return .IncludeIfMatched(.Amount(.Equals(0)))
            }
        }
        let expectedPredicate = NSPredicate(format: "SUBQUERY(friends, $CerberusItem, $CerberusItem.title == \"The Almighty Kraken\" OR $CerberusItem.age > \(age) OR $CerberusItem.isHungry == true OR ($CerberusItem.birthdate == %@ AND (NOT SUBQUERY($CerberusItem.subordinates, $ElfItem, $ElfItem.title == \"The Lowly Elf\").@count > 0) && SUBQUERY($CerberusItem.subordinates, $CerberusItem, $CerberusItem.birthdate == %@ || $CerberusItem.age == \(age)).@count > 0)).@count == 0", rightNow, rightNow)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testCombiningNSPredicateOperators() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = "October 4"
        let firstPredicate = NSPredicate(format: "title == %@ && birthdate == %@", theKrakensTitle, rightNow)
        let secondPredicate = NSPredicate(format: "isAwesome == true && isHungry == true")
        let combinedANDPredicate = firstPredicate && secondPredicate
        let combinedORPredicate = firstPredicate || secondPredicate
        XCTAssertEqual(combinedANDPredicate.predicateFormat, "(title == \"The Almighty Kraken\" AND birthdate == \"October 4\") AND (isAwesome == 1 AND isHungry == 1)")
        XCTAssertEqual(combinedORPredicate.predicateFormat, "(title == \"The Almighty Kraken\" AND birthdate == \"October 4\") OR (isAwesome == 1 AND isHungry == 1)")
    }
    
    func testNSArrayCollectionTypeConformance() {
        let foundationArray: NSArray = ["Kraken", "Cthulhu", "Voldemort", "Ember", "Umber", "Aslan"]
        let arraySliceIndex0To1: NSArray = ["Kraken", "Cthulhu"]
        let arraySliceIndex1ToLessThan4: NSArray = ["Cthulhu", "Voldemort", "Ember"]
        let arraySliceIndex2To5: NSArray = ["Voldemort", "Ember", "Umber", "Aslan"]

        XCTAssertEqual(foundationArray.startIndex, 0)
        XCTAssertEqual(foundationArray.endIndex, 6)
        XCTAssertEqual(foundationArray[0...1], arraySliceIndex0To1)
        XCTAssertEqual(foundationArray[1..<4], arraySliceIndex1ToLessThan4)
        XCTAssertEqual(foundationArray[2...5], arraySliceIndex2To5)
    }
}

//MARK: Test Classes
class Kraken: NSObject {
    var title: String?
    var age: Int64?
    var birthdate: NSDate?
    var isAwesome: Bool?
    var bestElfFriend: Elf?
    var friends: [Cerberus]?
}

class Cerberus: NSObject {
    var title: String?
    var age: Int64?
    var birthdate: NSDate?
    var isHungry: Bool?
    var subordinates: [Elf]?
}

class Elf: NSObject {
    var title: String?
    var enemy: Cerberus?
}
