//
//  Matchable.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 Used to give a query object the capability to perform SQL-like IN queries.
 */
public protocol Matchable: Queryable {
    /**
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in a `CollectionType`. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name IN %@", listOfObjects)
     
     "Fetch the `Kraken` object if the value of its `name` property matches any value in the `listOfObjects` array."
     
     - Parameters:
     - collection: An `Array` or `Set` of objects to match against.
     */
    @discardableResult func matchesAnyValueIn<U: Collection>(_ collection: U) -> FinalizedIncluder<BuilderType>
}

public extension Matchable {
    @discardableResult func matchesAnyValueIn<U: Collection>(_ collection: U) -> FinalizedIncluder<BuilderType> {
        builder.predicateString = "\(property) IN %@"
        builder.arguments.append(collection)
        return FinalizedIncluder(builder: builder, arguments: [collection])
    }
}
