//
//  NumberQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that queries against number properties in the `T` class.
 */
public final class NumberQuery<T: Reflectable>: NilComparable, Matchable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    required public init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    /**
     Equivalent to the `>` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age > 5")
     
     "Fetch the `Kraken` object if the value of its `age` property is greater than 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func isGreaterThan(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) > %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
    
    /**
     Equivalent to the `<` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age < 5")
     
     "Fetch the `Kraken` object if the value of its `age` property is less than 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func isLessThan(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) < %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
    
    /**
     Equivalent to the `>=` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age >= 5")
     
     "Fetch the `Kraken` object if the value of its `age` property is greater than or equal to 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func isGreaterThanOrEqualTo(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) >= %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
    
    /**
     Equivalent to the `<=` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age <= 5")
     
     "Fetch the `Kraken` object if the value of its `age` property is less than or equal to 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func isLessThanOrEqualTo(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) <= %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
    
    /**
     Equivalent to the `!=` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age != 5")
     
     "Fetch the `Kraken` object if the value of its `age` property does not equal 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func doesNotEqual(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) != %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
    
    /**
     Equivalent to the `==` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var age: Int
         }
         NSPredicate(format: "age == 5")
     
     "Fetch the `Kraken` object if the value of its `age` property equals 5"
     
     - Parameters:
     - number: The number to compare against the property's value.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    @discardableResult public func equals(_ number: Number) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(number)
        return FinalizedIncluder(builder: builder, arguments: [number])
    }
}
