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
        case isAwesome
        case isHungry
    }
    
    private init(_ name: Names) {
        self.init(name.rawValue)
    }
    
    static let title = Selector(.title)
    static let birthdate = Selector(.birthdate)
    static let isAwesome = Selector(.isAwesome)
    static let isHungry = Selector(.isHungry)
}