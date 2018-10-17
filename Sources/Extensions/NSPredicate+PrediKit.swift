//
//  PrediKit.swift
//  KrakenDev
//
//  Created by Hector Matos on 5/13/16.
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import Foundation

/**
 This is where the magic happens. This extension allows anyone to construct an `NSPredicate` from a closure.
 */
public extension NSPredicate {
    /**
     A generic convenience initializer that accepts a `Reflectable` type and a builder closure that allows you to construct includers that describe the resulting `NSPredicate` instance.

     - Parameters:
     - type: The `Reflectable` class type that you'll be querying against. The type you supply here is what PrediKit will inspect to ensure the property names you specify in your includers are contained in that class' property list.
     - builder: A closure that you use to generate includers that construct each subpredicate in the created `NSPredicate`
     */
    convenience init<T>(_ type: T.Type, builder: ((_ includeIf: PredicateBuilder<T>) -> Void)) {
        let predicateBuilder = PredicateBuilder(type: type)
        builder(predicateBuilder)
        
        if predicateBuilder.predicateString.isEmpty {
            self.init(value: false)
        } else {
            self.init(format: predicateBuilder.predicateString, argumentArray: predicateBuilder.arguments.compactMap({$0}))
        }
    }
}

/**
 Convenience infix `&&` operator that combines two `NSPredicate` instances into one ANDed `NSCompoundPredicate`
 */
@discardableResult public func && (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

/**
 Convenience infix `||` operator that combines two `NSPredicate` instances into one ORed `NSCompoundPredicate`
 */
@discardableResult public func || (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

