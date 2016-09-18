//
//  BooleanQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that queries against `Bool` properties in the `T` class.
 */
public final class BooleanQuery<T: Reflectable>: NilComparable, Matchable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    required public init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
             var isAwesome: Bool
         }
         NSPredicate(format: "isAwesome == true")
     
     "Fetch the `Kraken` object if the value of its `isAwesome` property is true"
     */
    @discardableResult public func isTrue() -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == true"
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
             var isAwesome: Bool
         }
         NSPredicate(format: "isAwesome == false")
     
     "Fetch the `Kraken` object if the value of its `isAwesome` property is false"
     */
    @discardableResult public func isFalse() -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == false"
        return FinalizedIncluder(builder: builder)
    }
}
