//
//  String+FeedElementIdentification.swift
//
//  Created by Nacho on 5/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation


let kDateDateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
let kDateTimeIntervalStringRegex = "^([0-9]{2}):([0-9]{2}):([0-9]{2})"

extension Date {
    func toDateDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateDateFormat
        return dateFormatter.string(from: self)
    }
    
    func toDateDateAndTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    func distanceToDateInDays(date: Date) -> Int {
        let flags: Set<Calendar.Component> = [Calendar.Component.day]
        let components = Calendar.current.dateComponents(flags, from: self, to: date)
        return components.day!
    }
    
    func distanceToDateInMinutes(date: Date) -> Int {
        let flags: Set<Calendar.Component> = [Calendar.Component.minute]
        let components = Calendar.current.dateComponents(flags, from: self, to: date)
        return components.minute!
    }
}
public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedSame
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

extension String {
    func toDateDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = kDateDateFormat
        return dateFormatter.date(from: self)
    }
    
    func toDateLocaleNotificationTimeString() -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = kDateDateFormat
        if let date = inputDateFormatter.date(from: self) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateStyle = .medium
            outputDateFormatter.timeStyle = .medium
            return outputDateFormatter.string(from: date)
        }
        
        return self // fallback
    }
}

extension TimeInterval {
    func toString() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

enum DateFormat {
    case iso8601, incompleteISO8601, dotNet, rfc822, incompleteRFC822
    case custom(String)
}

extension Date {
    
    // MARK: Intervals In Seconds
    fileprivate static func minuteInSeconds() -> Double { return 60 }
    fileprivate static func hourInSeconds() -> Double { return 3600 }
    fileprivate static func dayInSeconds() -> Double { return 86400 }
    fileprivate static func weekInSeconds() -> Double { return 604800 }
    fileprivate static func yearInSeconds() -> Double { return 31556926 }
    
    // MARK: Date From String
    
    
    init(fromString string: String, format:DateFormat)
    {
        if string.isEmpty {
            self.init()
            return
        }
        
        switch format {
            
        case .dotNet:
            
            // Expects "/Date(1268123281843)/"
            guard let milliseconds = string.substringBetween(initial: "(", final: ")")?.toFailableDouble() else { self.init(); return }
            let interval = TimeInterval(milliseconds / 1000)
            self.init(timeIntervalSince1970: interval)
            
        case .iso8601:
            
            var s = string
            if string.hasSuffix(" 00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            } else if string.hasSuffix("+00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            } else if string.hasSuffix("Z") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -1)) + "GMT"
            } else if string.hasSuffix("+0000") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -5)) + "GMT"
            }
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
            if let date = formatter.date(from: string as String) {
                self.init(timeInterval:0, since:date)
            } else {
                self.init()
            }
            
        case .incompleteISO8601:
            
            var s = string
            if string.hasSuffix(" 00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            } else if string.hasSuffix("+00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            } else if string.hasSuffix("Z") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -1)) + "GMT"
            } else if string.hasSuffix("+0000") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -5)) + "GMT"
            }
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            if let date = formatter.date(from: string as String) {
                self.init(timeInterval:0, since:date)
            } else {
                self.init()
            }
            
        case .rfc822:
            
            var s  = string
            if string.hasSuffix("Z") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -1)) + "GMT"
            } else if string.hasSuffix("+0000") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -5)) + "GMT"
            } else if string.hasSuffix("+00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            }
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
            if let date = formatter.date(from: string as String) {
                self.init(timeInterval:0, since:date)
            } else {
                self.init()
            }
            
        case .incompleteRFC822:
            
            var s  = string
            if string.hasSuffix("Z") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -1)) + "GMT"
            } else if string.hasSuffix("+0000") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -5)) + "GMT"
            } else if string.hasSuffix("+00:00") {
                s = s.substring(to: s.index(s.endIndex, offsetBy: -6)) + "GMT"
            }
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
            if let date = formatter.date(from: string as String) {
                self.init(timeInterval:0, since:date)
            } else {
                self.init()
            }
            
        case .custom(let dateFormat):
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = dateFormat
            if let date = formatter.date(from: string as String) {
                self.init(timeInterval:0, since:date)
            } else {
                self.init()
            }
        }
    }
    
    // MARK: Retrieving Intervals
    
    func minutesAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.minuteInSeconds())
    }
    
    func minutesBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.minuteInSeconds())
    }
    
    func hoursAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.hourInSeconds())
    }
    
    func hoursBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.hourInSeconds())
    }
    
    func daysAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.dayInSeconds())
    }
    
    func daysBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.dayInSeconds())
    }
    

    // MARK: To String
    
    func toString() -> String {
        return self.toString(dateStyle: .short, timeStyle: .short, doesRelativeDateFormatting: false)
    }
    
    func toString(format: DateFormat) -> String
    {
        var dateFormat: String
        switch format {
            case .dotNet:
                return "Date(\(self.timeIntervalSince1970))"
            case .iso8601:
                dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            case .rfc822:
                dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
            case .incompleteRFC822:
                dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
            case .incompleteISO8601:
                dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            case .custom(let string):
                dateFormat = string
        }
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }

    func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool = false) -> String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
        return formatter.string(from: self)
    }
   
}
