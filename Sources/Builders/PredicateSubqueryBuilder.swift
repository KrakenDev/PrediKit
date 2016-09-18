//
//  PredicateSubqueryBuilder.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that facilitates the creation of subqueries against `T`'s `CollectionType` properties. Used in tandem with the `SequenceQuery<T>` class.
 */
public final class PredicateSubqueryBuilder<T: Reflectable>: PredicateBuilder<T> {
    override init(type: T.Type) {
        super.init(type: type)
    }
    
    override func validatedProperty(_ property: Selector, file: String, line: Int) -> String {
        let subqueryProperty = super.validatedProperty(property, file: file, line: line)
        return "$\(String(describing: type))Item.\(subqueryProperty)"
    }
}
