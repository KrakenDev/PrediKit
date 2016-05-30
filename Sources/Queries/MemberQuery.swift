//
//  MemberQuery.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 A class that facilitates the creation of subqueries against `T`'s custom member properties. Since the creation of this class is initiated in the `PredicateBuilder<T>` class, and this class inherits from it, then member creation is recursive.
 */
public final class MemberQuery<T: Reflectable, MemberType: protocol<Reflectable, AnyObject>>: PredicateBuilder<T>, Matchable, NilComparable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    let memberType: MemberType.Type
    
    override var predicateString: String {
        didSet { builder.predicateString = predicateString }
    }
    
    override var arguments: [AnyObject?] {
        didSet { builder.arguments.appendContentsOf(arguments) }
    }
    
    init(builder: PredicateBuilder<T>, property: String, memberType: MemberType.Type) {
        self.builder = builder
        self.memberType = memberType
        self.property = property
        
        super.init(type: builder.type)
    }
    
    /**
     Creates an includer that determines if the property being queried is equivalent to an object of the same type as the property queried.
     */
    public func equals(object: MemberType) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(object)
        return FinalizedIncluder(builder: builder, arguments: [object])
    }
    
    override func validatedProperty(property: Selector, file: String = #file, line: Int = #line) -> String {
        if !memberType.properties().contains(property) && self.memberType != NSObject.self {
            #if DEBUG
                print("\(String(type)) does not seem to contain property \"\(property)\". This could be due to the optionality of a value type. Possible property key values:\n\(type.properties()).\nWarning in file:\(file) at line \(line)")
            #endif
        }
        
        return "\(self.property).\(String(property))"
    }
}