//
//  PrediKit.swift
//  KrakenDev
//
//  Created by Hector Matos on 5/13/16.
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import CoreData

/**
 Used to query the property list of the conforming class. PrediKit uses this protocol to determine if the property you are specifying in the creation of a predicate actually exists in the conforming class. 
 
 All `NSObject`s conform to this protocol through an extension.
 
 - Returns: An `Array` of `Selector`s. These can just be the strings detailing the properties of your class.
 */
public protocol Reflectable: class {
    static func properties() -> [Selector]
}

public protocol NilComparator {
    associatedtype CompareType: Reflectable
    var equalsNil: FinalizedPredicateQuery<CompareType> { get }
}

extension NSObject: Reflectable {
    public static func properties() -> [Selector] {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(self, &count)
        var propertyNames: [Selector] = []
        for i in 0..<Int(count) {
            if let propertyName = String(UTF8String: property_getName(properties[i])) {
                propertyNames.append(Selector(propertyName))
            }
        }
        
        free(properties)
        return propertyNames
    }
}

public extension NSPredicate {
    convenience init<T: Reflectable>(_ type: T.Type, file: String = #file, line: Int = #line, @noescape builder: ((include: PredicateBuilder<T>) -> Void)) {
        let predicateBuilder = PredicateBuilder(type: type)
        builder(include: predicateBuilder)
        
        let predicateFormat = predicateBuilder.currentPredicate?.predicateFormat ?? predicateBuilder.predicateString
        if let prettyFile = file.componentsSeparatedByString("/").last {
            print("Predicate created in \(prettyFile) at line \(line):\n\(predicateFormat)")
        }
        if predicateFormat.isEmpty {
            self.init(value: false)
        } else {
            self.init(format: predicateFormat)
        }
    }
}

public class PredicateBuilder<T: Reflectable> {
    public let type: T.Type
    private(set) var predicateString: String = ""
    private(set) var currentPredicate: NSPredicate?
    
    /**
     Used to indicate that you want to query the actual object checked when the predicate is run. Behaves like the `SELF` in the SQL-like query:
     ```
     NSPredicate(format: "SELF in names")
     ```
     */
    public var SELF: PredicateQueryBuilder<T> {
        return PredicateQueryBuilder(builder: self, property: "SELF")
    }
    
    init(type: T.Type) {
        self.type = type
    }
    
    /**
     Describes the key of class `T`'s `String` property you want to query. For example, when creating a predicate that compares a class' string property to a given string:
     ```
     class Kraken: NSObject {
        var theyCallMe: String
     }
     NSPredicate(format: "theyCallMe == 'Chief Supreme'")
     ```
     
     The `property` parameter would be the "theyCallMe" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    public func string(property: Selector, file: String = #file, line: Int = #line) -> PredicateStringQuery<T> {
        return PredicateStringQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s number type property you want to query. For example, when creating a predicate that compares a number property to a given value:
     ```
     class Kraken: NSObject {
        var numberOfHumansEaten: Int
     }
     NSPredicate(format: "numberOfHumansEaten >= 6")
     ```
     
     The `property` parameter would be the "numberOfHumansEaten" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    public func number(property: Selector, file: String = #file, line: Int = #line) -> PredicateNumberQuery<T> {
        return PredicateNumberQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `NSDate` property you want to query. For example, when creating a predicate compares a class' date property to another given date:
     ```
     class Kraken: NSObject {
        var birthdate: NSDate
     }
     NSPredicate(format: "birthdate == %@", NSDate())
     ```
     
     The `property` parameter would be the "birthdate" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    public func date(property: Selector, file: String = #file, line: Int = #line) -> PredicateDateQuery<T> {
        return PredicateDateQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `Bool` property you want to query. For example, when creating a predicate that checks against a given `Bool` flag in a class:
     ```
     class Kraken: NSObject {
        var isHungry: Bool
     }
     NSPredicate(format: "isHungry == true")
     ```
     
     The `property` parameter would be the "isHungry" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    public func bool(property: Selector, file: String = #file, line: Int = #line) -> PredicateBooleanQuery<T> {
        return PredicateBooleanQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `CollectionType` property you want to query. This is also the starting point for subqueries on list properties. For example, when creating a predicate that checks if a class' array property has 5 objects:
     ```
     class Kraken: NSObject {
        var friends: [LegendaryCreatures]
     }
     NSPredicate(format: "friends.@count == 5")
     ```
     
     The `property` parameter would be the "friends" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `#file`
     - line: Number of the line the function is being called from. Defaults to `#line`
     */
    public func collection(property: Selector, file: String = #file, line: Int = #line) -> PredicateSequenceQuery<T> {
        return PredicateSequenceQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    private func validatedProperty(property: Selector, file: String = #file, line: Int = #line) -> String {
        if !type.properties().contains(property) && self.type != NSObject.self {
            #if DEBUG
            print("\(String(type)) does not seem to contain property \"\(property)\". This could be due to the optionality of a value type. Possible property key values:\n\(type.properties()).\nWarning in file:\(file) at line \(line)")
            #endif
        }
        
        return String(property)
    }
}

public class PredicateQueryBuilder<T: Reflectable>: NilComparator {
    private let builder: PredicateBuilder<T>
    private var property: String
    public var equalsNil: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == nil"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    /**
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in an CollectionType.
     
     - Parameters:
     - array: An array of objects to match against. The array must only contain objects that conform to the `AnyObject` protocol. (All swift classes conform to this implicitly.)
     */
    public final func matchesAnyValueIn<U: CollectionType>(collection: U) -> FinalizedPredicateQuery<T> {
        if let collection = collection as? NSObject {
            builder.predicateString = NSPredicate(format: "\(property) IN %@", collection).predicateFormat
        }
        return FinalizedPredicateQuery(builder: builder)
    }
}

/**
 An OptionSetType that describes the options in which to create a string comparison.
 
 - CaseInsensitive: When comparing two strings, the predicate system will ignore case. For example, the characters 'e' and 'E' will match.
 - DiacriticInsensitive: When comparing two strings, the predicate system will ignore diacritic characters and normalize the special character to its base character. For example, the characters `e é ê è` are all equivalent.
 */
public struct PredicateOptions: OptionSetType {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let None =                 PredicateOptions(rawValue: 1<<0)
    public static let CaseInsensitive =      PredicateOptions(rawValue: 1<<1)
    public static let DiacriticInsensitive = PredicateOptions(rawValue: 1<<2)
}

public final class PredicateStringQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    public var isEmpty: FinalizedPredicateQuery<T> {
        return equals("")
    }
    
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public func beginsWith(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) BEGINSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func endsWith(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) ENDSWITH\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func contains(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) CONTAINS\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func matches(string: String, options: PredicateOptions = .None) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) MATCHES\(optionsString(options)) \"\(string)\""
        return FinalizedPredicateQuery(builder: builder)
    }
    
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

public final class PredicateNumberQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public func isGreaterThan(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) > %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLessThan(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) < %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isGreaterThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) >= %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLessThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) <= %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func doesNotEqual(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) != %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) == %@", number).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
}

public final class PredicateDateQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public func isLaterThan(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) > %@", date).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isEarlierThan(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) < %@", date).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLaterThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) >= %@", date).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isEarlierThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) <= %@", date).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) == %@", date).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
}

public final class PredicateBooleanQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public var isTrue: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == true"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public var isFalse: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == false"
        return FinalizedPredicateQuery(builder: builder)
    }
}

public enum SubqueryMatch {
    case IncludeIfMatched(MatchType)
    var collectionQuery: String {
        switch self {
        case .IncludeIfMatched(let matchType):
            return matchType.matchTypeString
        }
    }

    public enum MatchType {
        case Amount(CompareType)
        case CountMin(CompareType)
        case CountMax(CompareType)
        case CountAverage(CompareType)
        
        var matchTypeString: String {
            switch self {
            case .Amount(let compare): return "@count \(compare.compareString)"
            case .CountMin(let compare): return "@min \(compare.compareString)"
            case .CountMax(let compare): return "@max \(compare.compareString)"
            case .CountAverage(let compare): return "@avg \(compare.compareString)"
            }
        }

        public enum CompareType {
            case Equals(Int64)
            case GreaterThan(Int64)
            case GreaterThanOrEqualTo(Int64)
            case LessThan(Int64)
            case LessThanOrEqualTo(Int64)
            
            var compareString: String {
                switch self {
                case .Equals(let amount): return "== \(amount)"
                case .GreaterThan(let amount): return "> \(amount)"
                case .GreaterThanOrEqualTo(let amount): return ">= \(amount)"
                case .LessThan(let amount): return "< \(amount)"
                case .LessThanOrEqualTo(let amount): return "<= \(amount)"
                }
            }
        }
    }
}

public final class PredicateSequenceQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public var isEmpty: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property).@count == 0"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func subquery<U: NSObject where U: Reflectable>(type: U.Type, line: Int = #line, subbuilder: (includeIf: PredicateSubqueryBuilder<U>) -> SubqueryMatch) -> FinalizedPredicateQuery<T> {
        let subBuilder = PredicateSubqueryBuilder(type: type)
        let subqueryMatch = subbuilder(includeIf: subBuilder)

        let item = "$\(String(subBuilder.type))Item"
        let subqueryPredicate = NSPredicate(format: "(SUBQUERY(\(property), \(item), \(subBuilder.predicateString)).\(subqueryMatch.collectionQuery))")

        self.builder.predicateString = subqueryPredicate.predicateFormat
        return FinalizedPredicateQuery(builder: self.builder)
    }
}

public final class PredicateSubqueryBuilder<T: Reflectable>: PredicateBuilder<T> {
    private override init(type: T.Type) {
        super.init(type: type)
    }
    
    private override func validatedProperty(property: Selector, file: String, line: Int) -> String {
        let subqueryProperty = super.validatedProperty(property, file: file, line: line)
        return "$\(String(type))Item.\(subqueryProperty)"
    }
}

public final class FinalizedPredicateQuery<T: Reflectable> {
    private let builder: PredicateBuilder<T>
    private let finalizedPredicateString: String
    private(set) var finalPredicate: NSPredicate
    private(set) var ANDPredicatesToCombine: [NSPredicate] = []
    private(set) var ORPredicatesToCombine: [NSPredicate] = []
    
    init(builder: PredicateBuilder<T>) {
        self.builder = builder
        self.finalPredicate = NSPredicate(format: builder.predicateString)
        self.finalizedPredicateString = builder.predicateString
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

public func && (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func || (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

public func && <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return .combine(lhs, rhs: rhs, logicalAND: true)
}

public func || <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return .combine(lhs, rhs: rhs, logicalAND: false)
}

public prefix func ! <T>(rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    rhs.finalPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: rhs.finalPredicate)
    rhs.builder.predicateString = rhs.finalPredicate.predicateFormat
    return rhs
}
