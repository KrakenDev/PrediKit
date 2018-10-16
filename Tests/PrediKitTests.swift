//
//  PrediKitTests.swift
//  PrediKitTests
//
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import XCTest
import CoreData
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
        
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.SELF.equalsNil()
            XCTAssertEqual(includeIf.predicateString, "SELF == nil")
            includeIf.string(.krakenTitle).equalsNil()
            XCTAssertEqual(includeIf.predicateString, "title == nil")
            !includeIf.string(.krakenTitle).equalsNil()
            XCTAssertEqual(includeIf.predicateString, "!(title == nil)")
            includeIf.SELF.matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "SELF IN %@")
            includeIf.SELF.matchesAnyValueIn(legendarySet)
            XCTAssertEqual(includeIf.predicateString, "SELF IN %@")
            includeIf.member(.bestElfFriend, ofType: Elf.self).matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "bestElfFriend IN %@")
            includeIf.string(.krakenTitle).matchesAnyValueIn(legendaryArray)
            XCTAssertEqual(includeIf.predicateString, "title IN %@")
        }
    }
    
    func testStringIncluders() {
        let theKrakensTitle = "The Almighty Kraken"
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).isEmpty()
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title == \"\"", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).beginsWith(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).endsWith(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).contains(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).matches(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).equals(theKrakensTitle)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title == %@", theKrakensTitle).predicateFormat)
        }
    }
    
    func testStringIncludersWithOptions() {
        let theKrakensTitle = "The Almighty Kraken"
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).beginsWith(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).endsWith(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).contains(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[c] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).matches(theKrakensTitle, options: .CaseInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[c] %@", theKrakensTitle).predicateFormat)

            includeIf.string(.krakenTitle).beginsWith(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).endsWith(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).contains(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[d] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).matches(theKrakensTitle, options: .DiacriticInsensitive)
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[d] %@", theKrakensTitle).predicateFormat)

            includeIf.string(.krakenTitle).beginsWith(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title BEGINSWITH[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).endsWith(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title ENDSWITH[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).contains(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title CONTAINS[cd] %@", theKrakensTitle).predicateFormat)
            includeIf.string(.krakenTitle).matches(theKrakensTitle, options: [.CaseInsensitive, .DiacriticInsensitive])
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "title MATCHES[cd] %@", theKrakensTitle).predicateFormat)
        }
    }
    
    func testNumberIncluders() {
        let testAge = 5
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.number(.krakenAge).doesNotEqual(testAge)
            XCTAssertEqual(includeIf.predicateString, "age != %@")
            includeIf.number(.krakenAge).equals(testAge)
            XCTAssertEqual(includeIf.predicateString, "age == %@")
            includeIf.number(.krakenAge).isGreaterThan(testAge)
            XCTAssertEqual(includeIf.predicateString, "age > %@")
            includeIf.number(.krakenAge).isGreaterThanOrEqualTo(testAge)
            XCTAssertEqual(includeIf.predicateString, "age >= %@")
            includeIf.number(.krakenAge).isLessThan(testAge)
            XCTAssertEqual(includeIf.predicateString, "age < %@")
            includeIf.number(.krakenAge).isLessThanOrEqualTo(testAge)
            XCTAssertEqual(includeIf.predicateString, "age <= %@")
        }
    }
    
    func testDateIncluders() {
        let rightNow = Date()
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.date(.krakenBirthdate).equals(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate == %@")
            includeIf.date(.krakenBirthdate).isEarlierThan(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate < %@")
            includeIf.date(.krakenBirthdate).isEarlierThanOrOn(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate <= %@")
            includeIf.date(.krakenBirthdate).isLaterThan(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate > %@")
            includeIf.date(.krakenBirthdate).isLaterThanOrOn(rightNow)
            XCTAssertEqual(includeIf.predicateString, "birthdate >= %@")
        }
    }
    
    func testBoolIncluders() {
        let truePredicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.bool(.isAwesome).isTrue()
        }
        XCTAssertEqual(truePredicate.predicateFormat, NSPredicate(format: "isAwesome == true").predicateFormat)

        let falsePredicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.bool(.isAwesome).isFalse()
        }
        XCTAssertEqual(falsePredicate.predicateFormat, NSPredicate(format: "isAwesome == false").predicateFormat)
    }
    
    func testCollectionIncluders() {
        let _ = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).isEmpty()
            XCTAssertEqual(includeIf.predicateString, NSPredicate(format: "friends.@count == 0").predicateFormat)
        }
    }
    
    func testSubqueryIncluders() {
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).subquery(Cerberus.self) { includeIf in
                includeIf.bool(.isHungry).isTrue() &&
                includeIf.bool(.isAwesome).isTrue()
                return .includeIfMatched(.amount(.equals(0)))
            }
        }
        XCTAssertEqual(predicate.predicateFormat, NSPredicate(format: "SUBQUERY(friends, $CerberusItem, $CerberusItem.isHungry == true && $CerberusItem.isAwesome == true).@count == 0").predicateFormat)
    }
    
    func testSubqueryReturnTypeStrings() {
        let match = MatchType.includeIfMatched
        let amount = MatchType.FunctionType.amount
        XCTAssertEqual(match(amount(.equals(0))).collectionQuery, "@count == 0")
        XCTAssertEqual(match(amount(.isLessThan(0))).collectionQuery, "@count < 0")
        XCTAssertEqual(match(amount(.isLessThanOrEqualTo(0))).collectionQuery, "@count <= 0")
        XCTAssertEqual(match(amount(.isGreaterThan(0))).collectionQuery, "@count > 0")
        XCTAssertEqual(match(amount(.isGreaterThanOrEqualTo(0))).collectionQuery, "@count >= 0")

        let min = MatchType.FunctionType.minValue
        XCTAssertEqual(match(min(.equals(0))).collectionQuery, "@min == 0")
        XCTAssertEqual(match(min(.isLessThan(0))).collectionQuery, "@min < 0")
        XCTAssertEqual(match(min(.isLessThanOrEqualTo(0))).collectionQuery, "@min <= 0")
        XCTAssertEqual(match(min(.isGreaterThan(0))).collectionQuery, "@min > 0")
        XCTAssertEqual(match(min(.isGreaterThanOrEqualTo(0))).collectionQuery, "@min >= 0")

        let max = MatchType.FunctionType.maxValue
        XCTAssertEqual(match(max(.equals(0))).collectionQuery, "@max == 0")
        XCTAssertEqual(match(max(.isLessThan(0))).collectionQuery, "@max < 0")
        XCTAssertEqual(match(max(.isLessThanOrEqualTo(0))).collectionQuery, "@max <= 0")
        XCTAssertEqual(match(max(.isGreaterThan(0))).collectionQuery, "@max > 0")
        XCTAssertEqual(match(max(.isGreaterThanOrEqualTo(0))).collectionQuery, "@max >= 0")

        let avg = MatchType.FunctionType.averageValue
        XCTAssertEqual(match(avg(.equals(0))).collectionQuery, "@avg == 0")
        XCTAssertEqual(match(avg(.isLessThan(0))).collectionQuery, "@avg < 0")
        XCTAssertEqual(match(avg(.isLessThanOrEqualTo(0))).collectionQuery, "@avg <= 0")
        XCTAssertEqual(match(avg(.isGreaterThan(0))).collectionQuery, "@avg > 0")
        XCTAssertEqual(match(avg(.isGreaterThanOrEqualTo(0))).collectionQuery, "@avg >= 0")
    }
    
    func testMemberIncluders() {
        let elf = Elf()
        let elfName = "Aragorn"
        let enemyBirthdate = Date()
        let predicate = NSPredicate(Kraken.self) { includeIf in
            let bestElfFriend = includeIf.member(.bestElfFriend, ofType: Elf.self)
            let bestElfFriendsMortalEnemy = bestElfFriend.member(.enemy, ofType: Cerberus.self)

            !bestElfFriend.equalsNil() &&
            bestElfFriend.equals(elf) &&
            bestElfFriendsMortalEnemy.date(.cerberusBirthdate).equals(enemyBirthdate) &&
            bestElfFriend.string(.elfTitle).equals(elfName)
        }
        XCTAssertEqual(predicate.predicateFormat, NSPredicate(format: "!(bestElfFriend == nil) && bestElfFriend == %@ && bestElfFriend.enemy.birthdate == %@ && bestElfFriend.title == %@", elf, enemyBirthdate as CVarArg, elfName).predicateFormat)
    }
    
    func testSimpleANDIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).equals(theKrakensTitle) &&
            includeIf.date(.krakenBirthdate).isEarlierThan(rightNow)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ && birthdate < %@", theKrakensTitle, rightNow as CVarArg)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testChainedANDIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        let isAwesome = true
        let age = 5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).equals(theKrakensTitle) &&
            includeIf.date(.krakenBirthdate).isEarlierThan(rightNow) &&
            includeIf.bool(.isAwesome).isTrue() &&
            includeIf.number(.krakenAge).equals(age)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ && birthdate < %@ && isAwesome == %@ && age == \(age)", theKrakensTitle, rightNow as CVarArg, NSNumber(value: isAwesome))
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testSimpleORIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
            includeIf.date(.krakenBirthdate).isEarlierThan(rightNow)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ || birthdate < %@", theKrakensTitle, rightNow as CVarArg)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testChainedORIncluderCombination() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        let isAwesome = true
        let age = 5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
            includeIf.date(.krakenBirthdate).isEarlierThan(rightNow) ||
            includeIf.bool(.isAwesome).isTrue() ||
            includeIf.number(.krakenAge).equals(age)
        }
        let expectedPredicate = NSPredicate(format: "title == %@ || birthdate < %@ || isAwesome == %@ || age == \(age)", theKrakensTitle, rightNow as CVarArg, NSNumber(value: isAwesome))
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }
    
    func testComplexIncluderCombinationsWithoutParentheses() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
            includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
            includeIf.string(.krakenTitle).equals(theKrakensTitle) &&
            includeIf.date(.krakenBirthdate).equals(rightNow) ||
            includeIf.bool(.isAwesome).isTrue() &&
            includeIf.date(.krakenBirthdate).equals(rightNow) ||
            includeIf.bool(.isAwesome).isTrue()
        }
        let expectedPredicate = NSPredicate(format: "title == %@ || title == %@ || title == %@ && birthdate == %@ || isAwesome == true && birthdate == %@ || isAwesome == true", theKrakensTitle, theKrakensTitle, theKrakensTitle, rightNow as CVarArg, rightNow as CVarArg)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }

    func testComplexIncluderCombinationsWithParentheses() {
        let theKrakensTitle = "The Almighty Kraken"
        let rightNow = Date()
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            (includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
             includeIf.string(.krakenTitle).equals(theKrakensTitle) ||
             includeIf.string(.krakenTitle).equals(theKrakensTitle))
            &&
            (includeIf.date(.krakenBirthdate).equals(rightNow) ||
             includeIf.bool(.isAwesome).isTrue())
            &&
            (includeIf.date(.krakenBirthdate).equals(rightNow) ||
             includeIf.bool(.isAwesome).isTrue())
        }
        let expectedPredicate = NSPredicate(format: "(title == %@ || title == %@ || title == %@) && (birthdate == %@ || isAwesome == true) && (birthdate == %@ || isAwesome == true)", theKrakensTitle, theKrakensTitle, theKrakensTitle, rightNow as CVarArg, rightNow as CVarArg)
        XCTAssertEqual(predicate.predicateFormat, expectedPredicate.predicateFormat)
    }

    func testComplexIncluderCombinationsWithSubquery() {
        let theKrakensTitle = "The Almighty Kraken"
        let theElfTitle = "The Lowly Elf"
        let rightNow = Date()
        let age = 5.5
        
        let predicate = NSPredicate(Kraken.self) { includeIf in
            includeIf.collection(.friends).subquery(Cerberus.self) { includeIf in
                let isTheKraken = includeIf.string(.krakenTitle).equals(theKrakensTitle)
                let isBirthedToday = includeIf.date(.krakenBirthdate).equals(rightNow)
                let isHungry = includeIf.bool(.isHungry).isTrue()
                let isOlderThan5AndAHalf = includeIf.number(.krakenAge).isGreaterThan(age)
                let hasElfSubordinates = includeIf.collection(.subordinates).subquery(Elf.self) { includeIf in
                    includeIf.string(.elfTitle).equals(theElfTitle)
                    return .includeIfMatched(.amount(.isGreaterThan(0)))
                }
                let hasCerberusSubordinates = includeIf.collection(.subordinates).subquery(Cerberus.self) { includeIf in
                    let age = includeIf.number(.cerberusAge).equals(age)
                    let birthdate = includeIf.date(.cerberusBirthdate).equals(rightNow)
                    
                    birthdate || age
                    return .includeIfMatched(.amount(.isGreaterThan(0)))
                }
                
                isTheKraken || isOlderThan5AndAHalf || isHungry || (isBirthedToday && !hasElfSubordinates && hasCerberusSubordinates)
                
                return .includeIfMatched(.amount(.equals(0)))
            }
        }
        let expectedPredicate = NSPredicate(format: "SUBQUERY(friends, $CerberusItem, $CerberusItem.title == \"The Almighty Kraken\" OR $CerberusItem.age > \(age) OR $CerberusItem.isHungry == true OR ($CerberusItem.birthdate == %@ AND (NOT SUBQUERY($CerberusItem.subordinates, $ElfItem, $ElfItem.title == \"The Lowly Elf\").@count > 0) && SUBQUERY($CerberusItem.subordinates, $CerberusItem, $CerberusItem.birthdate == %@ || $CerberusItem.age == \(age)).@count > 0)).@count == 0", rightNow as CVarArg, rightNow as CVarArg)
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
}

//MARK: Test Classes
class Kraken: NSObject {
    @NSManaged var title: String
    @NSManaged var age: Int64
    @NSManaged var birthdate: Date
    @NSManaged var isAwesome: Bool
    @NSManaged var bestElfFriend: Elf
    @NSManaged var friends: [Cerberus]
}

class Cerberus: NSObject {
    @NSManaged var title: String
    @NSManaged var age: Int64
    @NSManaged var birthdate: Date
    @NSManaged var isHungry: Bool
    @NSManaged var subordinates: [Elf]
}

class Elf: NSObject {
    @NSManaged var title: String
    @NSManaged var enemy: Cerberus
}
