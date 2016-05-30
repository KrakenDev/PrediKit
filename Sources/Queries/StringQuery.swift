//
//  StringQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that queries against `String` properties in the `T` class.
 */
public final class StringQuery<T: Reflectable>: NilComparable, Matchable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    public var isEmpty: FinalizedIncluder<T> {
        return equals("")
    }
    
    required public init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to the `BEGINSWITH` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name BEGINSWITH \"K\"")
     
     "Fetch the `Kraken` object if the value of its `name` property begins with the letter 'K'"
     
     - Parameters:
     - string: The string to match the property's value against.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func beginsWith(string: String, options: PredicateOptions = .None) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) BEGINSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Equivalent to the `ENDSWITH` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name ENDSWITH \"n\"")
     
     "Fetch the `Kraken` object if the value of its `name` property ends with the letter 'n'"
     
     - Parameters:
     - string: The string to match the property's value against.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func endsWith(string: String, options: PredicateOptions = .None) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) ENDSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Equivalent to the `CONTAINS` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name CONTAINS \"rake\"")
     
     "Fetch the `Kraken` object if the value of its `name` property contains the word 'rake'"
     
     - Parameters:
     - string: The string to match the property's value against.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func contains(string: String, options: PredicateOptions = .None) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) CONTAINS\(optionsString(options)) \"\(string)\""
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Equivalent to the `MATCHES` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name MATCHES %@", regex)
     
     "Fetch the `Kraken` object if the value of its `name` property matches the regular expression pattern stored in the regex variable."
     
     - Parameters:
     - string: The string to match the property's value against.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func matches(string: String, options: PredicateOptions = .None) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) MATCHES\(optionsString(options)) \"\(string)\""
        return FinalizedIncluder(builder: builder)
    }
    
    /**
     Equivalent to the `==` operator. Equivalent to creating this predicate:
     
         class Kraken {
             var name: String
         }
         NSPredicate(format: "name == \"Kraken\"")
     
     "Fetch the `Kraken` object if the value of its `name` property equals the word 'Kraken'"
     
     - Parameters:
     - string: The string to match the property's value against.
     - options: Used to describe the sensitivity (diacritic or case) of the string comparator operation. Defaults to PredicateOptions.None
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func equals(string: String) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == \"\(string)\""
        return FinalizedIncluder(builder: builder)
    }
    
    private func optionsString(options: PredicateOptions) -> String {
        if !options.isEmpty && !options.contains(.None) {
            var string = "["
            if options.contains(.CaseInsensitive) {
                string = "\(string)c"
            }
            if options.contains(.DiacriticInsensitive) {
                string = "\(string)d"
            }
            return "\(string)]"
        }
        return ""
    }
}
