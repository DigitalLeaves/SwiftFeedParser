//
//  FeedItem.h
//
//  Created by Nacho on 7/9/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

let kReadyFeedItemImageMinSize: CGFloat = 75

@objc protocol FeedItemDelegate {
    // The feed item main image changed.
    func feedItem(feedItem: FeedItem, changedMainImage mainImage: UIImage)
}

class FeedItem: NSObject {
    // MARK: - mandatory
    var feedTitle: String?
    var feedLink: String?
    var feedContent: String? {
        didSet {
            self.contentWasUpdated()
        }
    }
    
    // MARK: - optional
    var feedContentSnippet: String?
    var feedPubDate: NSDate?
    var feedAuthor: String?
    var feedCategories: [String] = []
    var feedCommentsURL: String?
    var feedComments: [String] = []
    var feedEnclosures: [FeedEnclosure] = []
    var feedIdentifier: String?
    var feedSource: String? // rss channel where the feed came from, name or url.
    
    // MARK: - other
    var imageURLsFromDescription: [String]?
    var mainImage: UIImage? {
        didSet {
            if (mainImage != nil) {
                self.delegate?.feedItem(self, changedMainImage: mainImage!)
            }
        }
    }
    override var hashValue: Int {
        return self.isValid ? feedTitle!.hashValue ^ feedLink!.hashValue ^ feedContent!.hashValue : 0
    }
    var delegate: FeedItemDelegate?

    // MARK: - initializers
    convenience init(title: String, url: String, rawDescription: String) {
        self.init()
        self.feedTitle = title
        self.feedLink = url
        self.feedContent = rawDescription
        self.contentWasUpdated()
    }
    

    func contentWasUpdated(extraContent: String? = nil) -> Void{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let newImagesFromContent = extraContent == nil ? self.getImageURLsFromContent(self.feedContent ?? "") : self.getImageURLsFromContent(extraContent!)
            
            // set or add new images
            if (self.imageURLsFromDescription == nil) {
                self.imageURLsFromDescription = newImagesFromContent
            } else { if (self.imageURLsFromDescription != nil) { self.imageURLsFromDescription! += newImagesFromContent } }
        })
    }
    
    // MARK: - Load images from feeds.
    
    func getImageURLsFromContent(content: String) -> [String] {
        let regex = "['\"][^'|^\"]*?(?:png|jpg|jpeg|gif)[^'|^\"]*?['\"]"
        var substr = content
        var result: [String] = []
        while let match = substr.rangeOfString(regex, options: [.RegularExpressionSearch, .CaseInsensitiveSearch]) {
            var matchingString = substr.substringWithRange(match)
            matchingString = matchingString.substringFromIndex(matchingString.startIndex.successor())
            matchingString = matchingString.substringToIndex(matchingString.endIndex.predecessor())
            
            if matchingString.rangeOfString("http:", options: .CaseInsensitiveSearch) != nil || matchingString.rangeOfString("https://", options: .CaseInsensitiveSearch) != nil {
                result.append(matchingString)
            }
            substr = substr.substringFromIndex(match.startIndex.advancedBy(matchingString.characters.count))
        }
        return result
    }
    
    // MARK: - utility methods
    
    var isValid: Bool {
        if (feedTitle != nil && feedLink != nil && feedContent != nil) { return true }
        else { return false }
    }
    
    override var description: String {
        var desc = "Feed Item:\n"
            if (feedTitle != nil) { desc += "\t- Title: \(feedTitle)\n" }
            if (feedLink != nil) { desc += "\t- URL: \(feedLink)\n" }
            if (feedContent != nil) { desc += "\t- Description: \(feedContent)\n" }
            if (feedContentSnippet != nil) { desc += "\t- Content Snippet: \(feedContentSnippet)\n" }
            if (feedPubDate != nil) { desc += "\t- Pub Date: \(feedPubDate)\n" }
            if (feedAuthor != nil) { desc += "\t- Author: \(feedAuthor)\n" }
            if (feedCategories.count > 0) { desc += "\t- Categories: \(feedCategories)\n" }
            if (feedCommentsURL != nil) { desc += "\t- Comments URL: \(feedCommentsURL)\n" }
            if (!feedEnclosures.isEmpty) { desc += "\t- Enclosures: \(feedEnclosures)\n" }
            if (feedIdentifier != nil) { desc += "\t- Identifier: \(feedIdentifier)\n" }
            if (feedSource != nil) { desc += "\t- Source channel: \(feedSource)\n" }
            
            return desc + "\n"
    }

}

// Equality and comparision methods
func ==(lhs: FeedItem, rhs: FeedItem) -> Bool {
    return lhs.feedLink == rhs.feedLink
}