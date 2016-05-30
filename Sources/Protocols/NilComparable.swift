//
//  NilComparable.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 Used to give a query object the capability to perform nil comparison queries.
 */
public protocol NilComparable: Queryable {
    /**
     Creates an includer that determines if the property being queried is nil.
     */
    var equalsNil: FinalizedIncluder<BuilderType> { get }
}

public extension NilComparable {
    var equalsNil: FinalizedIncluder<BuilderType> {
        builder.predicateString = "\(property) == nil"
        return FinalizedIncluder(builder: builder)
    }
}
