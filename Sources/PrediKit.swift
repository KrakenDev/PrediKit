//
//  PrediKit.swift
//  KrakenDev
//
//  Created by Hector Matos on 5/13/16.
//  Copyright © 2016 KrakenDev. All rights reserved.
//

import CoreData

public protocol Reflectable: class {
    static func properties() -> [Selector]
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
    
    public var SELF: PredicateQueryBuilder<T> {
        return PredicateQueryBuilder(builder: self, property: "SELF")
    }
    
    init(type: T.Type) {
        self.type = type
    }
    
    public func string(property: Selector, file: String = #file, line: Int = #line) -> PredicateStringQuery<T> {
        return PredicateStringQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    public func number(property: Selector, file: String = #file, line: Int = #line) -> PredicateNumberQuery<T> {
        return PredicateNumberQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    public func date(property: Selector, file: String = #file, line: Int = #line) -> PredicateDateQuery<T> {
        return PredicateDateQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    public func bool(property: Selector, file: String = #file, line: Int = #line) -> PredicateBooleanQuery<T> {
        return PredicateBooleanQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    public func list(property: Selector, file: String = #file, line: Int = #line) -> PredicateSequenceQuery<T> {
        return PredicateSequenceQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    private func validatedProperty(property: Selector, file: String = #file, line: Int = #line) -> String {
        guard type.properties().contains(property) else {
            fatalError("\(String(type)) does not contain property \"\(property)\".\nFailed in file:\(file) at line \(line)")
        }
        return String(property)
    }
}

public class PredicateQueryBuilder<T: Reflectable> {
    private let builder: PredicateBuilder<T>
    private var property: String
    
    init(builder: PredicateBuilder<T>, property: String) {
        self.builder = builder
        self.property = property
    }
    
    public final func matchesAnyValueInArray<U: AnyObject>(array: Array<U>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(array)
    }
    
    public final func matchesAnyValueInSet<U: AnyObject>(set: Set<U>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(set)
    }
    
    public final func matchesAnyValueInDictionary<U: AnyObject, V: AnyObject>(dictionary: Dictionary<U, V>) -> FinalizedPredicateQuery<T> {
        return matchesAnyValueIn(dictionary)
    }
    
    private final func matchesAnyValueIn(collection: CVarArgType) -> FinalizedPredicateQuery<T> {
        builder.predicateString = NSPredicate(format: "\(property) IN %@", collection).predicateFormat
        return FinalizedPredicateQuery(builder: builder)
    }
    
    func finalizePredicateString() {
        builder.predicateString = "(\(property) != nil && \(builder.predicateString))"
    }
}

public final class PredicateStringQuery<T: Reflectable>: PredicateQueryBuilder<T> {
    private var oppositeDay: Bool = false
    public var doesNot: PredicateStringLogicalNotQuery<T> {
        return PredicateStringLogicalNotQuery(builder: self)
    }
    public var isEmpty: FinalizedPredicateQuery<T> {
        return equals("")
    }
    
    override init(builder: PredicateBuilder<T>, property: String) {
        super.init(builder: builder, property: property)
    }
    
    public func beginsWith(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) BEGINSWITH '\(string)'"
        finalizePredicateString()
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func endsWith(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) ENDSWITH '\(string)'"
        finalizePredicateString()
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func contains(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) CONTAINS '\(string)'"
        finalizePredicateString()
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func matches(string: String) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) MATCHES '\(string)'"
        finalizePredicateString()
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(string: String?) -> FinalizedPredicateQuery<T> {
        let operatorString = oppositeDay ? "!=" : "=="
        if let string = string {
            builder.predicateString = "\(property) \(operatorString) '\(string)'"
            finalizePredicateString()
            return FinalizedPredicateQuery(builder: builder)
        }
        builder.predicateString = "\(property) \(operatorString) nil"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    override func finalizePredicateString() {
        builder.predicateString = "(\(property) != nil && \(builder.predicateString))"
    }
}

public final class PredicateStringLogicalNotQuery<T: Reflectable> {
    private let builder: PredicateStringQuery<T>
    
    init(builder: PredicateStringQuery<T>) {
        builder.oppositeDay = true
        self.builder = builder
    }
    
    public func beginWith(string: String) -> FinalizedPredicateQuery<T> {
        return builder.beginsWith(string)
    }
    
    public func endWith(string: String) -> FinalizedPredicateQuery<T> {
        return builder.endsWith(string)
    }
    
    public func contain(string: String) -> FinalizedPredicateQuery<T> {
        return builder.contains(string)
    }
    
    public func match(string: String) -> FinalizedPredicateQuery<T> {
        return builder.matches(string)
    }
    
    public func equal(string: String?) -> FinalizedPredicateQuery<T> {
        return builder.equals(string)
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
        builder.predicateString = "\(property) > '\(date)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isEarlierThan(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) < '\(date)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isLaterThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) >= '\(date)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func isEarlierThanOrOn(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) <= '\(date)'"
        return FinalizedPredicateQuery(builder: builder)
    }
    
    public func equals(date: NSDate) -> FinalizedPredicateQuery<T> {
        builder.predicateString = "\(property) == '\(date)'"
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
    
    init(builder: PredicateBuilder<T>) {
        self.builder = builder
        self.finalPredicate = builder.predicateString.isEmpty ? nil : NSPredicate(format: builder.predicateString)
        self.finalizedPredicateString = builder.predicateString
    }
}

public func && (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func || (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

public func && <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return combine(lhs, rhs: rhs, logicalAND: true)
}

public func || <T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    return combine(lhs, rhs: rhs, logicalAND: false)
}

public prefix func ! <T>(rhs: FinalizedPredicateQuery<T>) -> FinalizedPredicateQuery<T> {
    guard let predicate = rhs.finalPredicate else { return rhs }
    rhs.finalPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    return rhs
}

private func combine<T>(lhs: FinalizedPredicateQuery<T>, rhs: FinalizedPredicateQuery<T>, logicalAND: Bool) -> FinalizedPredicateQuery<T> {
    if let lhsPredicate = lhs.finalPredicate, rhsPredicate = rhs.finalPredicate {
        let predicate: NSCompoundPredicate
        if logicalAND {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lhsPredicate, rhsPredicate])
        } else {
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [lhsPredicate, rhsPredicate])
        }
        lhs.builder.predicateString = ""
        lhs.builder.currentPredicate = predicate
        lhs.finalPredicate = predicate
        rhs.finalPredicate = predicate
        return lhs
    }
    return lhs
}
