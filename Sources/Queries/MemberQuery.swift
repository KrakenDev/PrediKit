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
public final class MemberQuery<T: Reflectable, MemberType: Reflectable & AnyObject>: PredicateBuilder<T>, Matchable, NilComparable {
    public let builder: PredicateBuilder<T>
    public let property: String
    
    let memberType: MemberType.Type
    
    override var predicateString: String {
        didSet { builder.predicateString = predicateString }
    }
    
    override var arguments: [Any?] {
        didSet { builder.arguments.append(contentsOf: arguments) }
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
    @discardableResult public func equals(_ object: MemberType) -> FinalizedIncluder<T> {
        builder.predicateString = "\(property) == %@"
        builder.arguments.append(object)
        return FinalizedIncluder(builder: builder, arguments: [object])
    }
    
    override func validatedProperty(_ property: String, file: String = #file, line: Int = #line) -> String {
        if !memberType.properties().contains(Selector(property)) && self.memberType != NSObject.self {
            #if DEBUG
                print("\(String(type)) does not seem to contain property \"\(property)\". This could be due to the optionality of a value type. Possible property key values:\n\(type.properties()).\nWarning in file:\(file) at line \(line)")
            #endif
        }
        
        return "\(self.property).\(String(describing: property))"
    }
}
