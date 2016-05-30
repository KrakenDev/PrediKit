//
//  Queryable.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 Indicates that a class can be used as a Query object.
 */
public protocol Queryable: class {
    /**
     A generic `Reflectable` that is used to maintain a consistent type throughout the creation of an includer.
     */
    typealias BuilderType: Reflectable
    
    /**
     A reference to the dependency-injected builder parameter passed in to PrediKit's `NSPredicate` closure initialization. Any changes made to this builder is reflected in the final outcome of the outputted `NSPredicate`.
     */
    var builder: PredicateBuilder<BuilderType> { get }
    /**
     The property to query against.
     */
    var property: String { get }
}
