//
//  String+FeedElementIdentification.swift
//
//  Created by Nacho on 5/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

enum DateFormat {
    case ISO8601, RFC822, IncompleteRFC822
    case Custom(String)
}

extension NSDate {
    // MARK: Date From String
    convenience init(fromString swiftString: String, format:DateFormat)
    {
        if swiftString.isEmpty {
            self.init()
            return
        }
        
        let string = swiftString as NSString
        
        switch format {
            case .ISO8601:
                
                var s = string
                if string.hasSuffix(" 00:00") {
                    s = s.substringToIndex(s.length-6) + "GMT"
                } else if string.hasSuffix("+00:00") {
                    s = s.substringToIndex(s.length-6) + "GMT"
                } else if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                } else if string.hasSuffix("+0000") {
                    s = s.substringToIndex(s.length-5) + "GMT"
                }

                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
                
            case .RFC822:
                
                var s  = string
                if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                } else if string.hasSuffix("+0000") {
                    s = s.substringToIndex(s.length-5) + "GMT"
                } else if string.hasSuffix("+00:00") {
                    s = s.substringToIndex(s.length-6) + "GMT"
                }
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
            
            case .IncompleteRFC822:
                
                var s  = string
                if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                } else if string.hasSuffix("+0000") {
                    s = s.substringToIndex(s.length-5) + "GMT"
                } else if string.hasSuffix("+00:00") {
                    s = s.substringToIndex(s.length-6) + "GMT"
                }
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
            
            case .Custom(let dateFormat):
                
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = dateFormat
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
        }
    }
     

    

    // MARK: To String
    
    func toString() -> String {
        return self.toString(dateStyle: .ShortStyle, timeStyle: .ShortStyle, doesRelativeDateFormatting: false)
    }
    
    func toString(format format: DateFormat) -> String
    {
        var dateFormat: String
        switch format {
            case .ISO8601:
                dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            case .RFC822:
                dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
            case .IncompleteRFC822:
                dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
            case .Custom(let string):
                dateFormat = string
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(self)
    }

    func toString(dateStyle dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle, doesRelativeDateFormatting: Bool = false) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
        return formatter.stringFromDate(self)
    }
   
}