//
//  Keypaths.swift
//  PrediKit
//
//  Created by Hector Matos on 5/16/16.
//
//

import Foundation

extension String {
    static let krakenTitle = #keyPath(Kraken.title)
    static let cerberusTitle = #keyPath(Cerberus.title)
    static let elfTitle = #keyPath(Elf.title)

    static let krakenAge = #keyPath(Kraken.age)
    static let cerberusAge = #keyPath(Cerberus.age)

    static let krakenBirthdate = #keyPath(Kraken.birthdate)
    static let cerberusBirthdate = #keyPath(Cerberus.birthdate)

    static let friends = #keyPath(Kraken.friends)
    static let bestElfFriend = #keyPath(Kraken.bestElfFriend)
    static let isAwesome = #keyPath(Kraken.isAwesome)

    static let subordinates = #keyPath(Cerberus.subordinates)
    static let isHungry = #keyPath(Cerberus.isHungry)
    
    static let enemy = #keyPath(Elf.enemy)
}
