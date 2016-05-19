//
//  Selectors.swift
//  PrediKit
//
//  Created by Hector Matos on 5/16/16.
//
//

import Foundation

extension Selector {
    private enum Names: String {
        case title
        case birthdate
        case age
        case friends
        case subordinates
        case isAwesome
        case isHungry
    }
    
    private init(_ name: Names) {
        self.init(name.rawValue)
    }
    
    static let title = Selector(.title)
    static let birthdate = Selector(.birthdate)
    static let age = Selector(.age)
    static let subordinates = Selector(.subordinates)
    static let friends = Selector(.friends)
    static let isAwesome = Selector(.isAwesome)
    static let isHungry = Selector(.isHungry)
}