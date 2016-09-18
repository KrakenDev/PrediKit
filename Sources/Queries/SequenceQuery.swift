//
//  SequenceQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that queries against `CollectionType` properties in the `T` class.
 */
public final class SequenceQuery<T: Reflectable>: NilComparable, Matchable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    required public init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
             var friends: [LegendaryCreature]
         }
         NSPredicate(format: "friends.@count == 0")
     
     "Fetch the `Kraken` object if it doesn't have any friends"
     */
    @discardableResult public func isEmpty() -> FinalizedIncluder<T> {
        builder.predicateString = "\(property).@count == 0"
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Creates a subpredicate that iterates through the collection property to return qualifying queries. Equivalent to creating this predicate:
     
         class Kraken {
             var friends: [LegendaryCreature]
         }
         NSPredicate(format: "SUBQUERY(friends, $friend, friend.isHungry == true).@count > 0")
     
     "Fetch the `Kraken` object if it has any friends that are hungry"
     
     - Parameters:
     - type: The type of the objects found in the collection property being subqueried.
     - subbuilder: A closure that defines queries that describe each object found in the collection property being subqueried. The closure must return an instance of the `SubqueryMatch` enum.
     */
    @discardableResult public func subquery<U: NSObject>(_ type: U.Type, subbuilder: (_ includeIf: PredicateSubqueryBuilder<U>) -> MatchType) -> FinalizedIncluder<T> where U: Reflectable {
        let subBuilder = PredicateSubqueryBuilder(type: type)
        let subqueryMatch = subbuilder(subBuilder)
        
        let item = "$\(String(describing: subBuilder.type))Item"
        let subqueryPredicate = "SUBQUERY(\(property), \(item), \(subBuilder.predicateString)).\(subqueryMatch.collectionQuery)"
        
        builder.predicateString = subqueryPredicate
        builder.arguments += subBuilder.arguments
        return FinalizedIncluder(builder: builder, arguments: builder.arguments)
    }
}
