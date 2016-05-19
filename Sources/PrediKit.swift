//
//  PrediKit.swift
//  KrakenDev
//
//  Created by Hector Matos on 5/13/16.
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import CoreData

// MARK: PredicateOptions
/**
 An `OptionSetType` that describes the options in which to create a string comparison.
 */
public struct PredicateOptions: OptionSetType {
    /**
     The raw value of the given `PredicateOptions` value.
     */
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /**
     The strictest comparison option. When comparing two strings, the left and right hand side MUST equal each other and is diacritic AND case-sensitive.
     */
    public static let None =                 PredicateOptions(rawValue: 1<<0)
    /**
     When comparing two strings, the predicate system will ignore case. For example, the characters 'e' and 'E' will match.
     */
    public static let CaseInsensitive =      PredicateOptions(rawValue: 1<<1)
    /**
     When comparing two strings, the predicate system will ignore diacritic characters and normalize the special character to its base character. For example, the characters `e é ê è` are all equivalent.
     */
    public static let DiacriticInsensitive = PredicateOptions(rawValue: 1<<2)
}

// MARK: SubqueryMatch Enum
/**
 An instance of this enum must be returned in the subquery closure to indicate how the queries collected in that closure
 */
public enum SubqueryMatch {
    /**
     The starting point of the subquery match type. You MUST include an associated value in this case to create a valid subquery predicate.
     */
    case IncludeIfMatched(MatchType)
    var collectionQuery: String {
        switch self {
        case .IncludeIfMatched(let matchType):
            return matchType.matchTypeString
        }
    }
    
    // MARK: MatchType Enum
    /**
     The next (second) point of the subquery match type that describes the predicate of the qualifying queries array return from the subquery. You MUST include an associated value in each case to create a valid subquery predicate.
     */
    public enum MatchType {
        /**
         Returns the collection.count value of the queried collection.
         */
        case Amount(CompareType)
        /**
         Returns the minimum value of every number in a queried number collection.
         */
        case MinValue(CompareType)
        /**
         Returns the maximum value of every number in a queried number collection.
         */
        case MaxValue(CompareType)
        /**
         Returns the average value of every number in a number collection. Best used against an array of numbers to get the average of all numbers in that array.
         */
        case AverageValue(CompareType)
        
        var matchTypeString: String {
            switch self {
            case .Amount(let compare): return "@count \(compare.compareString)"
            case .MinValue(let compare): return "@min \(compare.compareString)"
            case .MaxValue(let compare): return "@max \(compare.compareString)"
            case .AverageValue(let compare): return "@avg \(compare.compareString)"
            }
        }
        
        // MARK: CompareType Enum
        /**
         The last point of the subquery match type that describes the amount to compare against the values generated from the MatchType enum. You MUST include an associated value in each case to create a valid subquery predicate.
         */
        public enum CompareType {
            case Equals(Int64)
            case IsGreaterThan(Int64)
            case IsGreaterThanOrEqualTo(Int64)
            case IsLessThan(Int64)
            case IsLessThanOrEqualTo(Int64)
            
            var compareString: String {
                switch self {
                case .Equals(let amount): return "== \(amount)"
                case .IsGreaterThan(let amount): return "> \(amount)"
                case .IsGreaterThanOrEqualTo(let amount): return ">= \(amount)"
                case .IsLessThan(let amount): return "< \(amount)"
                case .IsLessThanOrEqualTo(let amount): return "<= \(amount)"
                }
            }
        }
    }
}

// MARK: Reflectable Protocol
/**
 Used to query the property list of the conforming class. PrediKit uses this protocol to determine if the property you are specifying in the creation of a predicate actually exists in the conforming class. If it doesn't, PrediKit will print a warning to the console.
 
 All `NSObject`s conform to this protocol through a public extension declared in PrediKit.
 */
public protocol Reflectable: class {
    /**
     Must implement this protocol in order to take advantage of PrediKit's property warning console print behavior.
     
     - Returns: An `Array` of `Selector`s. These can just be the strings that equal the names of the properties in your class.
     */
    static func properties() -> [Selector]
}

private var reflectedClasses: [String : [Selector]] = [:]

// MARK: NSObject Reflectable Extension
/**
 PrediKit is best used with CoreData `ManagedObject`s. Since each ManagedObject is an NSObject, PrediKit's `NSPredicate` creation works out of the box for all of your `ManagedObject` subclasses.
 */
extension NSObject: Reflectable {
    /**
     Uses the Objective-C Runtime to determine the list of properties in an NSObject subclass.
     
     - Returns: An `Array` of `Selector`s whose string values are equal to the names of each property in the NSObject subclass.
     */
    public static func properties() -> [Selector] {
        guard let savedPropertyList = reflectedClasses[String(self)] else {
            var count: UInt32 = 0
            let properties = class_copyPropertyList(self, &count)
            var propertyNames: [Selector] = []
            for i in 0..<Int(count) {
                if let propertyName = String(UTF8String: property_getName(properties[i])) {
                    propertyNames.append(Selector(propertyName))
                }
            }
            free(properties)

            reflectedClasses[String(self)] = propertyNames
            return propertyNames
        }
        return savedPropertyList
    }
}

// MARK: NSPredicate Convenience Initializers
/**
 This is where the magic happens. This extension allows anyone to construct an `NSPredicate` from a closure.
 */
public extension NSPredicate {
    /**
     A generic convenience initializer that accepts a `Reflectable` type and a builder closure that allows you to construct includers that describe the resulting `NSPredicate` instance.

     - Parameters:
     - type: The `Reflectable` class type that you'll be querying against. The type you supply here is what PrediKit will inspect to ensure the property names you specify in your includers are contained in that class' property list.
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     - builder: A closure that you use to generate includers that construct each subpredicate in the created `NSPredicate`
     */
    convenience init<T: Reflectable>(_ type: T.Type, @noescape builder: ((includeIf: PredicateBuilder<T>) -> Void)) {
        let predicateBuilder = PredicateBuilder(type: type)
        builder(includeIf: predicateBuilder)
        
        let predicateFormat = predicateBuilder.currentPredicate?.predicateFormat ?? predicateBuilder.predicateString

        if predicateFormat.isEmpty {
            self.init(value: false)
        } else {
            self.init(format: predicateFormat)
        }
    }
}

// MARK: PredicateBuilder
/**
 The class that gets passed into the builder closure of PrediKit's `NSPredicate` convenience initializer.
 */
public class PredicateBuilder<T: Reflectable> {
    private let type: T.Type
    private(set) var predicateString: String = ""
    private(set) var arguments: [NSObject] = []
    private(set) var currentPredicate: NSPredicate?
    
    /**
     Used to indicate that you want to query the actual object checked when the predicate is run. Behaves like the `SELF` in the SQL-like query:

         NSPredicate(format: "SELF in names")
     */
    public var SELF: PredicateQueryBuilder<T> {
        return PredicateQueryBuilder(builder: self, property: "SELF")
    }
    
    init(type: T.Type) {
        self.type = type
    }
    
    /**
     Describes the key of class `T`'s `String` property you want to query. For example, when creating a predicate that compares a class' string property to a given string:

         class Kraken: NSObject {
             var theyCallMe: String
         }
         NSPredicate(format: "theyCallMe == 'Chief Supreme'")
     
     The `property` parameter would be the "theyCallMe" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func string(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> PredicateStringQuery<T> {
        return PredicateStringQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s number type property you want to query. For example, when creating a predicate that compares a number property to a given value:

         class Kraken: NSObject {
             var numberOfHumansEaten: Int
         }
         NSPredicate(format: "numberOfHumansEaten >= 6")
     
     The `property` parameter would be the "numberOfHumansEaten" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func number(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> PredicateNumberQuery<T> {
        return PredicateNumberQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `NSDate` property you want to query. For example, when creating a predicate compares a class' date property to another given date:

         class Kraken: NSObject {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate == %@", NSDate())
     
     The `property` parameter would be the "birthdate" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func date(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> PredicateDateQuery<T> {
        return PredicateDateQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `Bool` property you want to query. For example, when creating a predicate that checks against a given `Bool` flag in a class:

         class Kraken: NSObject {
             var isHungry: Bool
         }
         NSPredicate(format: "isHungry == true")
     
     The `property` parameter would be the "isHungry" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func bool(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> PredicateBooleanQuery<T> {
        return PredicateBooleanQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `CollectionType` property you want to query. This is also the starting point for subqueries on list properties. For example, when creating a predicate that checks if a class' array property has 5 objects:

         class Kraken: NSObject {
             var friends: [LegendaryCreatures]
         }
         NSPredicate(format: "friends.@count == 5")
     
     The `property` parameter would be the "friends" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func collection(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> PredicateSequenceQuery<T> {
        return PredicateSequenceQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    private func validatedProperty(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> String {
        if !type.properties().contains(property) && self.type != NSObject.self {
            #if DEBUG
            print("\(String(type)) does not seem to contain property \"\(property)\". This could be due to the optionality of a value type. Possible property key values:\n\(type.properties()).\nWarning in file:\(file) at line \(line)")
            #endif
        }
        
        return String(property)
    }
}

// MARK: PredicateQueryBuilder
/**
 The class that all queries returned from each function in `PredicateBuilder<T>` inherits from. Provides common API for each type of QueryBuilder like `IN` operations and `SELF` operations.
 */
public class PredicateQueryBuilder<T: Reflectable> {
    private let builder: PredicateBuilder<T>
    private var property: String

    /**
     Creates an includer that determines if the property being queried is nil. The resulting predicate would be equivalent to this predicate:

         class Kraken: NSObject {
             var isAwesome: Bool?
         }
         NSPredicate(format: "isAwesome == nil")
     */
    public var equalsNil: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == nil"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in an CollectionType. Equivalent to creating this predicate:

         class Kraken {
             var name: String
         }
         NSPredicate(format: "name IN %@", listOfObjects)

     "Fetch the `Kraken` object if the value of its `name` property matches any value in the `listOfObjects` array."
     
     - Parameters:
     - collection: An `Array` or `Set` of objects to match against.
     */
    public final func matchesAnyValueIn<U: CollectionType>(collection: U) -> FinalizedPredicateQuery<T> {
        if let collection = collection as? NSObject {
            builder.predicateString = "\(property) IN %@"
            builder.arguments.append(collection)
        }
        return FinalizedPredicateQuery(builder: builder)
    }
}

// MARK: PredicateStringQuery
/**
 A class that queries against `String` properties in the `T` class.
 */
public final class PredicateStringQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    public var isEmpty: FinalizedPredicateQuery<T> {
        return equals("")
    }
    
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
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
    public func beginsWith(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) BEGINSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
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
    public func endsWith(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) ENDSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
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
    public func contains(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) CONTAINS\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
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
    public func matches(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) MATCHES\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
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
    public func equals(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
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

// MARK: PredicateNumberQuery
/**
 A class that queries against number properties in the `T` class.
 */
public final class PredicateNumberQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isGreaterThan(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) > %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isLessThan(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) < %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isGreaterThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) >= %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func isLessThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) <= %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func doesNotEqual(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) != %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
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
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func equals(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(number)
        return FinalizedPredicateQuery(builder: builder)
    }
}

// MARK: PredicateDateQuery
/**
 A class that queries against `NSDate` properties in the `T` class.
 */
public final class PredicateDateQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
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
    public func isLaterThan(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) > %@"
        builder.arguments.append(date)
        return FinalizedPredicateQuery(builder: builder)
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
    public func isEarlierThan(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) < %@"
        builder.arguments.append(date)
        return FinalizedPredicateQuery(builder: builder)
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
    public func isLaterThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) >= %@"
        builder.arguments.append(date)
        return FinalizedPredicateQuery(builder: builder)
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
    public func isEarlierThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) <= %@"
        builder.arguments.append(date)
        return FinalizedPredicateQuery(builder: builder)
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
    public func equals(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(date)
        return FinalizedPredicateQuery(builder: builder)
    }
}

// MARK: PredicateBooleanQuery
/**
 A class that queries against `Bool` properties in the `T` class.
 */
public final class PredicateBooleanQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
            var isAwesome: Bool
         }
         NSPredicate(format: "isAwesome == true")
     
     "Fetch the `Kraken` object if the value of its `isAwesome` property is true"
     */
    public var isTrue: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == true"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
            var isAwesome: Bool
         }
         NSPredicate(format: "isAwesome == false")
     
     "Fetch the `Kraken` object if the value of its `isAwesome` property is false"
     */
    public var isFalse: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == false"
        return FinalizedPredicateQuery(builder: builder)
    }
}

// MARK: PredicateSequenceQuery
/**
 A class that queries against `CollectionType` properties in the `T` class.
 */
public final class PredicateSequenceQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    /**
     Equivalent to creating this predicate:
     
         class Kraken {
            var friends: [LegendaryCreature]
         }
         NSPredicate(format: "friends.@count == 0")
     
     "Fetch the `Kraken` object if it doesn't have any friends"
     */
    public var isEmpty: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property).@count == 0"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    /**
     Creates a subpredicate that iterates through the collection property to return qualifying queries. Equivalent to creating this predicate:
     
         class Kraken {
            var friends: [LegendaryCreature]
         }
         NSPredicate(format: "SUBQUERY(friends, $friend, friend.isHungry == true).@count > 0")
     
     "Fetch the `Kraken` object if it has any friends that are hungry"

     - Parameters:
     - type: The type of the objects found in the collection property being subqueried.
     - subbuilder: A closure that defines queries that describe each object found in the collection property being subqueried. The closure must return an instance of the `SubqueryMatch` enum.
     */
    public func subquery<U: NSObject where U: Reflectable>(type: U.Type, subbuilder: (includeIf: PredicateSubqueryBuilder<U>) -> SubqueryMatch) -> FinalizedPredicateQuery<T> {
        let subBuilder = PredicateSubqueryBuilder(type: type)
        let subqueryMatch = subbuilder(includeIf: subBuilder)

        let item = "$\(String(subBuilder.type))Item"
        let subqueryPredicate = "SUBQUERY(\(property), \(item), \(subBuilder.predicateString)).\(subqueryMatch.collectionQuery)"

        self.builder.predicateString = subqueryPredicate
        return FinalizedPredicateQuery(builder: self.builder)
    }
}

// MARK: PredicateSubqueryBuilder
/**
 A class that facilitates the creation of subqueries against `T`'s `CollectionType` properties. Used in tandem with the `PredicateSequenceQuery<T>` class.
 */
public final class PredicateSubqueryBuilder<T: Reflectable>: PredicateBuilder<T> {
    private override init(type: T.Type) {
        super.init(type: type)
    }
    
    private override func validatedProperty(property: Selector, file: String, line: Int) -> String {
        let subqueryProperty = super.validatedProperty(property, file: file, line: line)
        return "$\(String(type))Item.\(subqueryProperty)"
    }
}

// MARK: FinalizedPredicateQuery
/**
 A class that finalizes an includer created within the builder closure of PrediKit's `NSPredicate` convenience initializer. All includers (basically any line of code within that closure) must end in a call to a function that returns an instance or subclassed instance of this class to create a valid `NSPredicate`.
 */
public final class FinalizedPredicateQuery<T: Reflectable> {
    private let builder: PredicateBuilder<T>
    private let finalizedPredicateString: String
    private(set) var finalPredicate: NSPredicate
    private(set) var ANDPredicatesToCombine: [NSPredicate] = []
    private(set) var ORPredicatesToCombine: [NSPredicate] = []
    
    init(builder: PredicateBuilder<T>) {
        self.builder = builder
        self.finalPredicate = NSPredicate(format: builder.predicateString, argumentArray: builder.arguments)
        self.finalizedPredicateString = builder.predicateString
        self.builder.arguments.removeAll()
    }
   
    private static func combine<T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>, logicalAND: Bool) -> FinalizedPredicateQuery<T> {
        let lhsPredicate = lhs.finalPredicate
        let rhsPredicate = rhs.finalPredicate
        let predicate: NSCompoundPredicate
        
        var lhsPredicatesToCombine = logicalAND ? lhs.ANDPredicatesToCombine : lhs.ORPredicatesToCombine
        var rhsPredicatesToCombine = logicalAND ? rhs.ANDPredicatesToCombine : rhs.ORPredicatesToCombine

        if lhsPredicatesToCombine.isEmpty && rhsPredicatesToCombine.isEmpty {
            rhsPredicatesToCombine = [lhsPredicate, rhsPredicate]
            lhsPredicatesToCombine = rhsPredicatesToCombine
        } else if rhsPredicatesToCombine.isEmpty {
            //Operators associate to the left so there's no need to check if the lhs combination predicate array is empty since it will always have something if it gets here by failing the first check.
            lhsPredicatesToCombine.append(rhsPredicate)
            rhsPredicatesToCombine = lhsPredicatesToCombine
        } else {
            lhsPredicatesToCombine += rhsPredicatesToCombine
            rhsPredicatesToCombine = lhsPredicatesToCombine
        }
        
        if logicalAND {
            lhs.ANDPredicatesToCombine = lhsPredicatesToCombine
            rhs.ANDPredicatesToCombine = rhsPredicatesToCombine
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: lhsPredicatesToCombine)
        } else {
            lhs.ORPredicatesToCombine = lhsPredicatesToCombine
            rhs.ORPredicatesToCombine = rhsPredicatesToCombine
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: lhs.ORPredicatesToCombine)
        }
        
        lhs.builder.predicateString = predicate.predicateFormat
        lhs.builder.currentPredicate = predicate
        lhs.finalPredicate = predicate
        rhs.finalPredicate = predicate
        return lhs
    }
}

// MARK: NSPredicate Convenience Combinators
/**
 Convenience infix `&&` operator that combines two `NSPredicate` instances into one ANDed `NSCompoundPredicate`
 */
public func && (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

/**
 Convenience infix `||` operator that combines two `NSPredicate` instances into one ORed `NSCompoundPredicate`
 */
public func || (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

// MARK: Query Includer Operators
/**
 Convenience infix `&&` operator that combines two `FinalizedPredicateQuery<T>` instances into one `FinalizedPredicateQuery<T>` that represents the ANDed compound of the `finalizedPredicate` properties in each instance.
 
 Essentially, you use this operator to join together two includers.
 */
public func && <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return .combine(lhs, rhs: rhs, logicalAND: true)
}

/**
 Convenience infix `||` operator that combines two `FinalizedPredicateQuery<T>` instances into one `FinalizedPredicateQuery<T>` that represents the ORed compound of the `finalizedPredicate` properties in each instance.
 
 Essentially, you use this operator to join together two includers.
 */
public func || <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return .combine(lhs, rhs: rhs, logicalAND: false)
}

/**
 Convenience prefix `!` operator that turns `FinalizedPredicateQuery<T>` into its NOT version.
 
 Essentially, you use this operator to indicate the opposite of an includer.
 */
public prefix func ! <T>(rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    rhs.finalPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: rhs.finalPredicate)
    rhs.builder.predicateString = rhs.finalPredicate.predicateFormat
    return rhs
}
