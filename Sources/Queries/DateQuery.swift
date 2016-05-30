//
//  DateQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that queries against `NSDate` properties in the `T` class.
 */
public final class DateQuery<T: Reflectable>: NilComparable, Matchable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    required public init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to the infix `>` operator for two dates. Equivalent to creating this predicate:
     
         class Kraken {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate > %@", halloween2008)
     
     "Fetch the `Kraken` object if it was born later than halloween2008"
     
     - Parameters:
     - date: The date to compare against the property's value.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isLaterThan(date: NSDate) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) > %@"
        builder.arguments.append(date)
        return FinalizedIncluder(builder: builder, arguments: [date])
    }
    
    /**
     Equivalent to the infix `<` operator for two dates. Equivalent to creating this predicate:
     
         class Kraken {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate < %@", halloween2008)
     
     "Fetch the `Kraken` object if it was born earlier than halloween2008"
     
     - Parameters:
     - date: The date to compare against the property's value.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isEarlierThan(date: NSDate) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) < %@"
        builder.arguments.append(date)
        return FinalizedIncluder(builder: builder, arguments: [date])
    }
    
    /**
     Equivalent to the infix `>=` operator for two dates. Equivalent to creating this predicate:
     
         class Kraken {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate >= %@", halloween2008)
     
     "Fetch the `Kraken` object if it was born on halloween2008 or later than halloween2008"
     
     - Parameters:
     - date: The date to compare against the property's value.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isLaterThanOrOn(date: NSDate) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) >= %@"
        builder.arguments.append(date)
        return FinalizedIncluder(builder: builder, arguments: [date])
    }
    
    /**
     Equivalent to the infix `<=` operator for two dates. Equivalent to creating this predicate:
     
         class Kraken {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate <= %@", halloween2008)
     
     "Fetch the `Kraken` object if it was born on halloween2008 or earlier than halloween2008"
     
     - Parameters:
     - date: The date to compare against the property's value.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isEarlierThanOrOn(date: NSDate) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) <= %@"
        builder.arguments.append(date)
        return FinalizedIncluder(builder: builder, arguments: [date])
    }
    
    /**
     Equivalent to the infix `==` operator for two dates. Equivalent to creating this predicate:
     
         class Kraken {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate == %@", halloween2008)
     
     "Fetch the `Kraken` object if it was born on halloween2008"
     
     - Parameters:
     - date: The date to compare against the property's value.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func equals(date: NSDate) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(date)
        return FinalizedIncluder(builder: builder, arguments: [date])
    }
}
