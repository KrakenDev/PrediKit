//
//  SubqueryMatchTypes.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

// MARK: MatchType Enum
/**
 An instance of this enum must be returned in the subquery closure to indicate how the queries collected in that closure should be matched to pass the predicate.
 */
public enum MatchType {
    /**
     The starting point of the subquery match type. You MUST include an associated value in this case to create a valid subquery predicate.
     */
    case includeIfMatched(FunctionType)
    var collectionQuery: String {
        switch self {
        case .includeIfMatched(let matchType):
            return matchType.matchTypeString
        }
    }
    
    // MARK: FunctionType Enum
    /**
     The type of the associated value of the each case in the `MatchType` enum. Used to indicate what function to use to match returned query collections with.
     */
    public enum FunctionType {
        /**
         Returns the collection.count value of the queried collection.
         */
        case amount(CompareType)
        /**
         Returns the minimum value of every number in a queried number collection.
         */
        case minValue(CompareType)
        /**
         Returns the maximum value of every number in a queried number collection.
         */
        case maxValue(CompareType)
        /**
         Returns the average value of every number in a number collection. Best used against an array of numbers to get the average of all numbers in that array.
         */
        case averageValue(CompareType)
        
        var matchTypeString: String {
            switch self {
            case .amount(let compare): return "@count \(compare.compareString)"
            case .minValue(let compare): return "@min \(compare.compareString)"
            case .maxValue(let compare): return "@max \(compare.compareString)"
            case .averageValue(let compare): return "@avg \(compare.compareString)"
            }
        }
        
        // MARK: CompareType Enum
        /**
         The type of the associated value of the each case in the `FunctionType` enum. Used to indicate how to compare the value of the function that's used to match returned query collections with.
         */
        public enum CompareType {
            case equals(Int64)
            case isGreaterThan(Int64)
            case isGreaterThanOrEqualTo(Int64)
            case isLessThan(Int64)
            case isLessThanOrEqualTo(Int64)
            
            var compareString: String {
                switch self {
                case .equals(let amount): return "== \(amount)"
                case .isGreaterThan(let amount): return "> \(amount)"
                case .isGreaterThanOrEqualTo(let amount): return ">= \(amount)"
                case .isLessThan(let amount): return "< \(amount)"
                case .isLessThanOrEqualTo(let amount): return "<= \(amount)"
                }
            }
        }
    }
}
