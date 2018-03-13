//
//  Reflectable.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

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

/**
 PrediKit is best used with instances of CoreData's `NSManagedObject`. Since each `NSManagedObject` is an `NSObject`, PrediKit's `NSPredicate` creation works out of the box for all of your `NSManagedObject` subclasses.
 */
private var reflectedClasses: [String : [Selector]] = [:]
extension NSObject: Reflectable {
    /**
     Uses the Objective-C Runtime to determine the list of properties in an NSObject subclass.
     
     - Returns: An `Array` of `Selector`s whose string values are equal to the names of each property in the NSObject subclass.
     */
    public static func properties() -> [Selector] {
        guard let savedPropertyList = reflectedClasses[String(describing: self)] else {
            var count: UInt32 = 0
            let properties = class_copyPropertyList(self, &count)
            var propertyNames: [Selector] = []
            for i in 0..<Int(count) {
                if let currentProperty = properties?[i], let propertyName = String(validatingUTF8: property_getName(currentProperty)) {
                    propertyNames.append(Selector(propertyName))
                }
            }
            free(properties)
            
            reflectedClasses[String(describing: self)] = propertyNames
            return propertyNames
        }
        return savedPropertyList
    }
}
