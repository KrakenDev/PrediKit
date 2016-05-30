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
    case IncludeIfMatched(FunctionType)
    var collectionQuery: String {
        switch self {
        case .IncludeIfMatched(let matchType):
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
        case Amount(CompareType)
        /**
         Returns the minimum value of every number in a queried number collection.
         */
        case MinValue(CompareType)
        /**
         Returns the maximum value of every number in a queried number collection.
         */
        case MaxValue(CompareType)
        /**
         Returns the average value of every number in a number collection. Best used against an array of numbers to get the average of all numbers in that array.
         */
        case AverageValue(CompareType)
        
        var matchTypeString: String {
            switch self {
            case .Amount(let compare): return "@count \(compare.compareString)"
            case .MinValue(let compare): return "@min \(compare.compareString)"
            case .MaxValue(let compare): return "@max \(compare.compareString)"
            case .AverageValue(let compare): return "@avg \(compare.compareString)"
            }
        }
        
        // MARK: CompareType Enum
        /**
         The type of the associated value of the each case in the `FunctionType` enum. Used to indicate how to compare the value of the function that's used to match returned query collections with.
         */
        public enum CompareType {
            case Equals(Int64)
            case IsGreaterThan(Int64)
            case IsGreaterThanOrEqualTo(Int64)
            case IsLessThan(Int64)
            case IsLessThanOrEqualTo(Int64)
            
            var compareString: String {
                switch self {
                case .Equals(let amount): return "== \(amount)"
                case .IsGreaterThan(let amount): return "> \(amount)"
                case .IsGreaterThanOrEqualTo(let amount): return ">= \(amount)"
                case .IsLessThan(let amount): return "< \(amount)"
                case .IsLessThanOrEqualTo(let amount): return "<= \(amount)"
                }
            }
        }
    }
}
