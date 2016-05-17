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
            guard let propertyName = String(UTF8String: property_getName(properties[i])) else {
                continue
            }
            
            propertyNames.append(Selector(propertyName))
        }
        
        free(properties)
        return propertyNames
    }
}

public extension NSPredicate {
    convenience init(file: String = #file, line: Int = #line, @noescape builder: ((include: PredicateBuilder<NSObject>) -> Void)) {
        self.init(NSObject.self, file: file, line: line, builder: builder)
    }
    
    convenience init<T: Reflectable>(_ type: T.Type, file: String = #file, line: Int = #line, @noescape builder: ((include: PredicateBuilder<T>) -> Void)) {
        let predicateBuilder = PredicateBuilder(type: type)
        builder(include: predicateBuilder)
        
        let predicateFormat = predicateBuilder.currentPredicate?.predicateFormat ?? predicateBuilder.predicateString
        if let prettyFile = file.componentsSeparatedByString("/").last {
            print("Predicate created in \(prettyFile) at line \(line):\n\(predicateFormat)")
        }
        self.init(format: predicateFormat)
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
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in an `Array`.
     
     - Parameters:
     - array: An array of objects to match against. The array must only contain objects that conform to the `AnyObject` protocol. (All swift classes conform to this implicitly.)
     */
    public final func matchesAnyValueInArray<U: AnyObject>(array: Array<U>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(array)
    }
    
    /**
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in a `Set`.
     
     - Parameters:
     - set: A set of objects to match against. The set must only contain objects that conform to the `AnyObject` protocol. (All swift classes conform to this implicitly.)
     */
    public final func matchesAnyValueInSet<U: AnyObject>(set: Set<U>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(set)
    }
    
    /**
     Equivalent to the SQL-like `IN` operator where a predicate is created to match if a class' property matches ANY value in a dictionary's `values` array.
     
     - Parameters:
     - set: A dictionary of objects to match against. The dictionary must only contain keys and values that conform to the `AnyObject` protocol. (All swift classes conform to this implicitly.)
     */
    public final func matchesAnyValueInDictionary<U: AnyObject, V: AnyObject>(dictionary: Dictionary<U, V>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(dictionary)
    }
    
    private final func matchesAnyValueIn(collection: CVarArgType) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) IN %@", collection).predicateFormat
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
    
    public static let CaseInsensitive = PredicateOptions(rawValue: 1<<0)
    public static let DiacriticInsensitive = PredicateOptions(rawValue: 1<<1)
}

public final class PredicateStringQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    public var isEmpty: FinalizedPredicateQuery<T> {
        return equals("")
    }
    
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public func beginsWith(string: String, options: PredicateOptions = [.CaseInsensitive, .DiacriticInsensitive]) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) BEGINSWITH\(optionsString(options)) '\(string)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func endsWith(string: String, options: PredicateOptions = [.CaseInsensitive, .DiacriticInsensitive]) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) ENDSWITH\(optionsString(options)) '\(string)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func contains(string: String, options: PredicateOptions = [.CaseInsensitive, .DiacriticInsensitive]) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) CONTAINS\(optionsString(options)) '\(string)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func matches(string: String, options: PredicateOptions = [.CaseInsensitive, .DiacriticInsensitive]) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) MATCHES\(optionsString(options)) '\(string)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == '\(string)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    private func optionsString(options: PredicateOptions) -> String {
        if !options.isEmpty {
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
        builder.predicateString = "\(property) > '\(number)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLessThan(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) < '\(number)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isGreaterThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) >= '\(number)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLessThanOrEqualTo(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) <= '\(number)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func doesNotEqual(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) != '\(number)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(number: NSNumber) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == '\(number)'"
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

public enum SubqueryMatchContainedType {
    case MatchAnyOfTheAbove
    case NoneOfTheAbove
    case MatchElementAmount(MatchedElementAmount)
    
    public enum MatchedElementAmount {
        case Equals(Int64)
        case GreaterThan(Int64)
        case GreaterThanOrEqualTo(Int64)
        case LessThan(Int64)
        case LessThanOrEqualTo(Int64)
    }
}

public final class PredicateSequenceQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public var isEmpty: FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property).count == 0"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func subquery<U: NSObject where U: Reflectable>(type: U.Type, line: Int = #line, builder: (include: PredicateSubqueryBuilder<U>) -> SubqueryMatchContainedType) -> FinalizedPredicateQuery<T> {
        let subBuilder = PredicateSubqueryBuilder(type: type)
        let matchType = builder(include: subBuilder)
        
        let containsCheck: String
        switch matchType {
        case .MatchAnyOfTheAbove: containsCheck = "@count > 0"
        case .NoneOfTheAbove: containsCheck = "@count == 0"
        case .MatchElementAmount(let matchElementAmount):
            switch matchElementAmount {
            case .Equals(let amount): containsCheck = "@count == \(amount)"
            case .GreaterThan(let amount): containsCheck = "@count > \(amount)"
            case .GreaterThanOrEqualTo(let amount): containsCheck = "@count >= \(amount)"
            case .LessThan(let amount): containsCheck = "@count < \(amount)"
            case .LessThanOrEqualTo(let amount): containsCheck = "@count <= \(amount)"
            }
        }
        
        let itemQueryName = "$\(String(subBuilder.type))Item"
        let currentPredicate = subBuilder.currentPredicate?.predicateFormat ?? subBuilder.predicateString
        let subqueryPredicate = NSPredicate(format: "(SUBQUERY(\(property), \(itemQueryName), \(currentPredicate)).\(containsCheck))")
        let finalizedBuilder = FinalizedPredicateQuery(builder: self.builder)
        
        if let currentPredicate = self.builder.currentPredicate {
            self.builder.currentPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [currentPredicate, subqueryPredicate])
        } else {
            self.builder.currentPredicate = subqueryPredicate
        }
        finalizedBuilder.finalPredicate = self.builder.currentPredicate
        return finalizedBuilder
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
    private(set) var finalPredicate: NSPredicate?
    private(set) var ANDPredicatesToCombine: [NSPredicate] = []
    private(set) var ORPredicatesToCombine: [NSPredicate] = []
    
    init(builder: PredicateBuilder<T>) {
        self.builder = builder
        self.finalPredicate = builder.predicateString.isEmpty ? nil : NSPredicate(format: builder.predicateString)
        self.finalizedPredicateString = builder.predicateString
    }
   
    private static func combine<T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>, logicalAND: Bool) -> FinalizedPredicateQuery<T> {
        if let lhsPredicate = lhs.finalPredicate, rhsPredicate = rhs.finalPredicate {
            let predicate: NSCompoundPredicate
            
            var lhsPredicatesToCombine = logicalAND ? lhs.ANDPredicatesToCombine : lhs.ORPredicatesToCombine
            var rhsPredicatesToCombine = logicalAND ? rhs.ANDPredicatesToCombine : rhs.ORPredicatesToCombine
            if lhsPredicatesToCombine.isEmpty && rhsPredicatesToCombine.isEmpty {
                rhsPredicatesToCombine = [lhsPredicate, rhsPredicate]
                lhsPredicatesToCombine = rhsPredicatesToCombine
            } else if lhsPredicatesToCombine.isEmpty {
                rhsPredicatesToCombine.append(lhsPredicate)
                lhsPredicatesToCombine = rhsPredicatesToCombine
            } else if rhsPredicatesToCombine.isEmpty {
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
            
            lhs.builder.predicateString = ""
            lhs.builder.currentPredicate = predicate
            lhs.finalPredicate = predicate
            rhs.finalPredicate = predicate
            return lhs
        }
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
    guard let predicate = rhs.finalPredicate else { return rhs }
    rhs.finalPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    return rhs
}
