//
//  FeedChannel.swift
//
//  Created by Nacho on 7/9/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class FeedChannel: NSObject {
    // MARK: - mandatory properties
    var channelTitle: String?
    var channelURL: String?     // url of the RSS feed
    var channelLink: String?    // link to the site
    
    // MARK: - optional properties
    var channelDescription: String?
    var channelLogoURL: String?
    var channelLogo: UIImage?
    var channelLanguage: String?
    var channelDateOfLastChange: NSDate?
    var channelCategory: String?
    var channelID: Int? // from the READY API
    
    override var hashValue: Int {
        return self.isValid ? channelTitle!.hashValue ^ channelURL!.hashValue ^ channelLink!.hashValue : 0
    }
    
    convenience init(url: String, title: String, link:String) {
        self.init()
        self.channelURL = url
        self.channelTitle = title
        self.channelLink = link
    }

    // MARK: - utility methods
    var isValid: Bool {
        if (channelTitle != nil && channelURL != nil && channelLink != nil) { return true }
        else { return false }
    }
    
    override var description: String {
        var desc = "\nFeedChannel:\n"
        if (channelTitle != nil) { desc += "\t- Title: \(channelTitle)\n" }
        if (channelURL != nil) { desc += "\t- URL: \(channelURL)\n" }
        if (channelLink != nil) { desc += "\t- Link: \(channelLink)\n" }
        if (channelID != nil) { desc += "\t- ID (Ready): \(channelID)\n" }
        if (channelDescription != nil) { desc += "\t- Description: \(channelDescription)\n" }
        if (channelLogoURL != nil) { desc += "\t- Logo URL: \(channelLogoURL)\n" }
        if (channelLanguage != nil) { desc += "\t- Language: \(channelLanguage)\n" }
        if (channelDateOfLastChange != nil) { desc += "\t- Date of last change: \(channelDateOfLastChange)\n" }
        if (channelCategory != nil) { desc += "\t- Category: \(channelCategory)\n" }
        
        return desc + "\n"
    }
    
}

func == (lhs: FeedChannel, rhs: FeedChannel) -> Bool {
    return lhs.channelURL == rhs.channelURL
}
