//
//  String+Utilities.swift
//  FeedParser
//
//  Created by Ignacio Nieto Carvajal on 9/10/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

extension String {
    func substringBetween(initial: String, final: String) -> String? {
        guard var startIndex = self.range(of: initial)?.lowerBound  else { return nil } // initial string not found
        startIndex = self.index(startIndex, offsetBy: 1)
        guard let endIndex = self.range(of: final, options: [] , range: Range(uncheckedBounds: (startIndex, self.endIndex)), locale: nil)?.lowerBound else { return nil } // final string not found from initial.
        let range = Range(uncheckedBounds: (startIndex, endIndex))
        return self.substring(with: range)
    }
    
    func toFailableBool() -> Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
    
    func toBool() -> Bool {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return false
        }
    }
    
    func toDouble() -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.number(from: self.replacingOccurrences(of: ",", with: "."))?.doubleValue ?? 0.0
    }
    
    func toFailableDouble() -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.number(from: self.replacingOccurrences(of: ",", with: "."))?.doubleValue ?? 0.0
    }
    
    func toInt() -> Int {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }
    
    func toFailableInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
}
