//
//  PredicateOptions.swift
//  KrakenDev
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 An `OptionSetType` that describes the options in which to create a string comparison.
 */
public struct PredicateOptions: OptionSetType {
    /**
     The raw value of the given `PredicateOptions` value.
     */
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /**
     The strictest comparison option. When comparing two strings, the left and right hand side MUST equal each other and is diacritic AND case-sensitive.
     */
    public static let None = PredicateOptions(rawValue: 1<<0)
    /**
     When comparing two strings, the predicate system will ignore case. For example, the characters 'e' and 'E' will match.
     */
    public static let CaseInsensitive = PredicateOptions(rawValue: 1<<1)
    /**
     When comparing two strings, the predicate system will ignore diacritic characters and normalize the special character to its base character. For example, the characters `e é ê è` are all equivalent.
     */
    public static let DiacriticInsensitive = PredicateOptions(rawValue: 1<<2)
}
