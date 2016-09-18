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
    @discardableResult func equalsNil() -> FinalizedIncluder<BuilderType>
}

public extension NilComparable {
    @discardableResult func equalsNil() -> FinalizedIncluder<BuilderType> {
        builder.predicateString = "\(property) == nil"
        return FinalizedIncluder(builder: builder)
    }
}
