//
//  FinalizedIncluder.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that finalizes an includer created within the builder closure of PrediKit's `NSPredicate` convenience initializer. All includers (basically any line of code within that closure) must end in a call to a function that returns an instance or subclassed instance of this class to create a valid `NSPredicate`.
 */
public final class FinalizedIncluder<T: Reflectable> {
    fileprivate let builder: PredicateBuilder<T>
    fileprivate var finalArguments: [Any?]
    
    fileprivate(set) var finalPredicateString: String
    fileprivate(set) var ANDPredicatesToCombine: [String] = []
    fileprivate(set) var ORPredicatesToCombine: [String] = []
    
    init(builder: PredicateBuilder<T>, arguments: [Any?] = []) {
        self.builder = builder
        self.finalPredicateString = builder.predicateString
        self.finalArguments = arguments
    }
    
    fileprivate static func combine<T>(_ lhs: FinalizedIncluder<T>, rhs: FinalizedIncluder<T>, logicalAND: Bool) -> FinalizedIncluder<T> {
        let lhsPredicate = lhs.finalPredicateString
        let rhsPredicate = rhs.finalPredicateString
        let predicateFormat: String
        
        var lhsPredicatesToCombine = logicalAND ? lhs.ANDPredicatesToCombine : lhs.ORPredicatesToCombine
        var rhsPredicatesToCombine = logicalAND ? rhs.ANDPredicatesToCombine : rhs.ORPredicatesToCombine
        
        if lhsPredicatesToCombine.isEmpty && rhsPredicatesToCombine.isEmpty {
            lhsPredicatesToCombine = [lhsPredicate, rhsPredicate]
            rhsPredicatesToCombine = lhsPredicatesToCombine
        } else if rhsPredicatesToCombine.isEmpty {
            //Operators associate to the left so there's no need to check if the lhs combination predicate array is empty since it will always have something if it gets here by failing the first check.
            lhsPredicatesToCombine.append(rhsPredicate)
            rhsPredicatesToCombine = lhsPredicatesToCombine
        } else {
            lhsPredicatesToCombine.append(contentsOf: rhsPredicatesToCombine)
            rhsPredicatesToCombine = lhsPredicatesToCombine
        }
        
        if logicalAND {
            lhs.ANDPredicatesToCombine = lhsPredicatesToCombine
            rhs.ANDPredicatesToCombine = lhsPredicatesToCombine
            
            predicateFormat = "(\(lhsPredicatesToCombine.joined(separator: " && ")))"
        } else {
            lhs.ORPredicatesToCombine = lhsPredicatesToCombine
            rhs.ORPredicatesToCombine = lhsPredicatesToCombine
            
            predicateFormat = "(\(lhsPredicatesToCombine.joined(separator: " || ")))"
        }
        
        lhs.finalPredicateString = predicateFormat
        
        lhs.builder.predicateString = lhs.finalPredicateString
        rhs.builder.predicateString = lhs.builder.predicateString
        
        lhs.finalArguments = lhs.finalArguments + rhs.finalArguments
        rhs.finalArguments = lhs.finalArguments
        lhs.builder.arguments = lhs.finalArguments
        rhs.builder.arguments = lhs.finalArguments
        
        return lhs
    }
}

/**
 Convenience infix `&&` operator that combines two `FinalizedIncluder<T>` instances into one `FinalizedIncluder<T>` that represents the ANDed compound of the `finalizedPredicate` properties in each instance.
 
 Essentially, you use this operator to join together two includers.
 */
@discardableResult public func && <T>(lhs: FinalizedIncluder<T>, rhs: FinalizedIncluder<T>) -> FinalizedIncluder<T> {
    return .combine(lhs, rhs: rhs, logicalAND: true)
}

/**
 Convenience infix `||` operator that combines two `FinalizedIncluder<T>` instances into one `FinalizedIncluder<T>` that represents the ORed compound of the `finalizedPredicate` properties in each instance.
 
 Essentially, you use this operator to join together two includers.
 */
@discardableResult public func || <T>(lhs: FinalizedIncluder<T>, rhs: FinalizedIncluder<T>) -> FinalizedIncluder<T> {
    return .combine(lhs, rhs: rhs, logicalAND: false)
}

/**
 Convenience prefix `!` operator that turns `FinalizedIncluder<T>` into its NOT version.
 
 Essentially, you use this operator to indicate the opposite of an includer.
 */
@discardableResult public prefix func ! <T>(rhs: FinalizedIncluder<T>) -> FinalizedIncluder<T> {
    rhs.finalPredicateString = "!(\(rhs.finalPredicateString))"
    rhs.builder.predicateString = rhs.finalPredicateString
    return rhs
}
