//
//  NSArray+PrediKit.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

extension NSArray: CollectionType {
    public typealias SubSequence = [AnyObject]
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return count }
    
    public subscript (bounds: Range<Int>) -> [AnyObject] {
        return subarrayWithRange(NSRange(location: bounds.startIndex, length: bounds.endIndex - bounds.startIndex))
    }
}
