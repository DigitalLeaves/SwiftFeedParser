//
//  FeedParser.swift
//
//  Created by Nacho on 28/9/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

let kReadyDefaultMaxFeedsToParse = 20
let kReadyRSS1ChannelName = "channel"
let kReadyRSS2ChannelName = "channel"
let kReadyAtomChannelName = "feed"



enum FeedType: String {
    case Unknown = "unknown", Atom = "feed", RSS1 = "rdf:RDF", RSS1Alt = "RDF", RSS2 = "rss"
    
    func feedsDateFormat() -> DateFormat? {
        switch self {
        case .Atom:
            return .ISO8601
        case .RSS1:
            return .ISO8601
        case .RSS2:
            return .RFC822
        default:
            return .RFC822
        }
    }
}

enum ParsingType {
    case Full, ItemsOnly, ChannelOnly
}

enum ParsingStatus {
    case Stopped, Parsing, Succeed, Aborted, Failed;
}

@objc protocol FeedParserDelegate {
    optional func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel)
    optional func feedParser(parser: FeedParser, didParseItem item: FeedItem)
    optional func feedParser(parser: FeedParser, successfullyParsedURL url: String)
    optional func feedParser(parser: FeedParser, parsingFailedReason reason: String)
    optional func feedParserParsingAborted(parser: FeedParser)
}

/** The feed parser parses a feed URL and communicates the results to its delegate */
class FeedParser: NSObject, NSXMLParserDelegate {
    // parsing delegate
    var delegate: FeedParserDelegate?
    
    // Parser properties
    var feedType: FeedType! = .Unknown
    var parsingType: ParsingType
    var parsingStatus: ParsingStatus
    var feedURL: String
    var feedRawContents: NSData?
    var feedEncoding = NSUTF8StringEncoding
    var feedParser: NSXMLParser?
    var maxFeedsToParse = kReadyDefaultMaxFeedsToParse
    var feedItemsParsed = 0
    
    // Temporal parsing values
    var currentPath: String = "/"
    var currentElementIdentifier: String!
    var currentElementAttributes: [NSObject: AnyObject]!
    var currentElementContent: String!
    var currentFeedChannel: FeedChannel!
    var currentFeedItem: FeedItem!
    
    init(feedURL: String) {
        self.feedURL = feedURL
        self.parsingType = .Full
        self.parsingStatus = .Stopped
    }
    
    convenience init(feedURL: String, feedRawContents: NSData) {
        self.init(feedURL: feedURL)
        self.feedRawContents = feedRawContents
    }
    
    // MARK: - Parsing methods
    
    /** Resets the parser status, aborting any parsing process */
    func reset() {
        if (parsingStatus == .Parsing) {
            feedParser?.abortParsing()
        }
        parsingStatus = .Stopped
        currentElementIdentifier = nil
        currentElementAttributes = nil
        currentElementContent = nil
        currentFeedChannel = nil
        currentFeedItem = nil
        currentPath = "/"
        parsingType = .Full
        feedEncoding = NSUTF8StringEncoding
        feedType = .Unknown
        feedItemsParsed = 0
    }
    
    /** Starts the parsing process, requesting the feed URL content and parsing it with the NSXMLParser */
    func parse() {
        if (parsingStatus == .Parsing) {
            delegate?.feedParser?(self, parsingFailedReason: NSLocalizedString("another_parsing_in_process", comment: ""))
            return
        }
        self.reset()
        
        // Request the feed and start parsing.
        
        if (feedRawContents != nil) { // already downloaded content?
            feedParser = NSXMLParser(data: feedRawContents!)
        } else { // retrieve content and start parsing.
            feedParser = NSXMLParser(contentsOfURL: NSURL(string: feedURL)!)
        }
        if (feedParser != nil) { // content successfully retrieved
            self.parsingStatus = .Parsing
            self.feedParser!.shouldProcessNamespaces = true
            self.feedParser!.shouldResolveExternalEntities = false
            self.feedParser!.delegate = self
            self.feedParser!.parse()
        } else { // unable to retrieve content
            self.parsingStatus = .Failed
            self.delegate?.feedParser?(self, parsingFailedReason: NSString(format: "%@: %@", NSLocalizedString("unable_retrieve_feed_contents",comment: ""), self.feedURL) as String)
        }
        
    }
    
    func abortParsing() {
        if (parsingStatus == .Parsing) {
            feedParser?.abortParsing()
        }
        parsingStatus = .Aborted
        delegate?.feedParserParsingAborted?(self)
    }
    
    // MARK: - NSXMLParser methods
    
    // MARK: -- Element start
    
    /** Did start element. */
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        autoreleasepool {
            self.currentPath = NSURL(fileURLWithPath: self.currentPath).URLByAppendingPathComponent(qName!).path!
            self.currentElementIdentifier = elementName
            self.currentElementAttributes = attributeDict
            self.currentElementContent = ""
            
            // Determine the type of feed.
            if elementName == FeedType.Atom.rawValue { self.feedType = .Atom; return }
            if elementName == FeedType.RSS1.rawValue || elementName == FeedType.RSS1Alt.rawValue { self.feedType = .RSS1; return }
            if elementName == FeedType.RSS2.rawValue { self.feedType = .RSS2; return }
            
            // parse depending on feed type
            if (self.feedType == .Atom) { self.parseStartOfAtomElement(elementName, attributes: attributeDict) }
            if (self.feedType == .RSS2) { self.parseStartOfRSS2Element(elementName, attributes: attributeDict) }
            if (self.feedType == .RSS1) { self.parseStartOfRSS1Element(elementName, attributes: attributeDict) }
        }
    }
    
    func parseStartOfAtomElement(elementName: String, attributes attributeDict: [NSObject: AnyObject]!) {
        // start of atom feed channel
        if self.currentPath == "/feed" {
            initializeNewFeedChannel(attributeDict)
            return
        }
        
        // start of atom feed item
        if self.currentPath == "/feed/entry" {
            initializeNewFeedItem()
        }
    }
    
    func parseStartOfRSS2Element(elementName: String, attributes attributeDict: [NSObject: AnyObject]!) {
        // start of atom feed channel
        if self.currentPath == "/rss/channel" {
            initializeNewFeedChannel(attributeDict)
            return
        }
        
        // start of atom feed item
        if self.currentPath == "/rss/channel/item" {
            initializeNewFeedItem()
        }
    }
    
    func parseStartOfRSS1Element(elementName: String, attributes attributeDict: [NSObject: AnyObject]!) {
        // start of atom feed channel
        if self.currentPath == "/rdf:RDF/channel" {
            initializeNewFeedChannel(attributeDict)
            return
        }
        
        // start of atom feed item
        if self.currentPath == "/rdf:RDF/item" {
            initializeNewFeedItem()
        }
    }
    
    func initializeNewFeedChannel(attributeDict: [NSObject: AnyObject]!) {
        self.currentFeedChannel = FeedChannel()
        self.currentFeedChannel.channelURL = self.feedURL
        if (self.feedType == .Atom) { // language of the channel is included in attribute xml:lang for Atom.
            for (name, value) in attributeDict {
                if name == "xml:lang" {
                    self.currentFeedChannel?.channelLanguage = value as? String
                    break
                }
            }
        }
    }
    
    func initializeNewFeedItem() {
        // if we are looking just for the channel information, stop the parser right away.
        if (self.parsingType == .ChannelOnly) { // do we have a valid channel?
            if self.currentFeedChannel?.isValid == true { self.successfullyCloseParsingAndReturnJustChannel(self.currentFeedChannel) }
            else {
                self.abortParsingAndReportFailure("Failed to find a valid feed channel.")
            }
            self.currentFeedChannel = nil
            return
        } else { // process items.
            // when we find the first item we can store the previously found channel information:
            if (self.currentFeedChannel != nil) {
                if (self.currentFeedChannel?.isValid == true) {
                    self.delegate?.feedParser?(self, didParseChannel: self.currentFeedChannel)
                }
                self.currentFeedChannel = nil
            }
            // set current feed item
            self.currentFeedItem = FeedItem()
            self.currentFeedItem.feedSource = self.currentFeedChannel?.channelTitle ?? self.feedURL
            return
        }
    }

    // MARK: -- Element end
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        autoreleasepool {
            // parse depending on feed type
            if self.feedType == .Atom { self.parseEndOfAtomElement(elementName, qualifiedName: qName) }
            if self.feedType == .RSS1 { self.parseEndOfRSS1Element(elementName, qualifiedName: qName) }
            if self.feedType == .RSS2 { self.parseEndOfRSS2Element(elementName, qualifiedName: qName) }
        }
    }
    
    func parseEndOfAtomElement(elementName: String, qualifiedName qName: String!) {
        // item
        if self.currentPath == "/feed/entry" {
            if (self.currentFeedItem?.isValid == true) {
                self.delegate?.feedParser?(self, didParseItem: self.currentFeedItem)
            }
            self.currentFeedItem = nil
            
            // check for max items
            self.feedItemsParsed++
            if (self.feedItemsParsed >= self.maxFeedsToParse) { // parse up to maxFeedsToParse
                self.successfullyCloseParsingAfterMaxItemsFound()
            }
        }
            
        // title
        else if self.currentPath == "/feed/title" {
            self.currentFeedChannel?.channelTitle = self.currentElementContent
        }
        else if self.currentPath == "/feed/entry/title" {
            self.currentFeedItem?.feedTitle = self.currentElementContent
        }
            
        // link
        else if self.currentPath == "/feed/link" {
            if (self.feedType == .Atom) {
                self.parseAtomLink(self.currentPath, attributes: self.currentElementAttributes, content: self.currentElementContent);
            } else { self.currentFeedChannel?.channelLink = self.currentElementContent }
        }
        else if self.currentPath == "/feed/entry/link" {
            if (self.feedType == .Atom) {
                if (self.currentElementAttributes?["href"] != nil) && (self.currentElementAttributes?["rel"] == nil) {
                    self.currentFeedItem?.feedLink = self.currentElementAttributes["href"] as? String
                }
            } else { self.currentFeedItem?.feedLink = self.currentElementContent }
        }
            
        // description -- content
        else if self.currentPath == "/feed/description" {
            self.currentFeedChannel?.channelDescription = self.currentElementContent
        }
        else if self.currentPath == "/feed/entry/content" {
            self.currentFeedItem?.feedContent = self.currentElementContent
        }
            
        // pub date
        else if self.currentPath == "/feed/updated" {
            self.currentFeedChannel?.channelDateOfLastChange = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
        else if self.currentPath == "/feed/entry/updated" {
            self.currentFeedItem?.feedPubDate = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
            
        // category
        else if self.currentPath == "/feed/category" {
            self.currentFeedChannel?.channelCategory = self.currentElementAttributes?["term"] as? String
        }
        else if self.currentPath == "/feed/entry/category" {
            if let category = self.currentElementAttributes?["term"] as? String {
                self.currentFeedItem?.feedCategories.append(category)
            }
        }
            
        // author (feed items only)
        else if self.currentPath == "/feed/entry/author/name" {
            self.currentFeedItem?.feedAuthor = self.currentElementContent
        }
            
        // GUID / Identifier
        else if self.currentPath == "/feed/entry/id" {
            self.currentFeedItem?.feedIdentifier = self.currentElementContent
        }
        
        // clear elements
        self.currentElementAttributes = nil
        self.currentElementIdentifier = nil
        self.currentElementContent = nil
        
        self.currentPath = (NSURL(fileURLWithPath: self.currentPath).URLByDeletingLastPathComponent?.path)!

    }
    
    func parseEndOfRSS2Element(elementName: String, qualifiedName qName: String!) {
        // item
        if self.currentPath == "/rss/channel/item" {
            if (self.currentFeedItem?.isValid == true) {
                self.delegate?.feedParser?(self, didParseItem: self.currentFeedItem)
            }
            self.currentFeedItem = nil
            
            // check for max items
            self.feedItemsParsed++
            if (self.feedItemsParsed >= self.maxFeedsToParse) { // parse up to maxFeedsToParse
                self.successfullyCloseParsingAfterMaxItemsFound()
            }
        }
            
        // title
        else if self.currentPath == "/rss/channel/title" {
            self.currentFeedChannel?.channelTitle = self.currentElementContent
        }
        else if self.currentPath == "/rss/channel/item/title" {
            self.currentFeedItem?.feedTitle = self.currentElementContent
        }
            
        // link
        else if self.currentPath == "/rss/channel/link" {
            self.currentFeedChannel?.channelLink = self.currentElementContent
        }
        else if self.currentPath == "/rss/channel/item/link" {
            self.currentFeedItem?.feedLink = self.currentElementContent
        }
            
        // description -- content
        else if self.currentPath == "/rss/channel/description" {
            self.currentFeedChannel?.channelDescription = self.currentElementContent
        }
        else if self.currentPath == "/rss/channel/item/description" {
            self.currentFeedItem?.feedContent = self.currentElementContent
        }
            
        // pub date
        else if self.currentPath == "/rss/channel/item/lastBuildDate" {
            self.currentFeedChannel?.channelDateOfLastChange = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
        else if self.currentPath == "/rss/channel/item/pubDate" {
            self.currentFeedItem?.feedPubDate = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
            
        // language (channels only)
        else if self.currentPath == "/rss/channel/language" {
            self.currentFeedChannel?.channelLanguage = self.currentElementContent
        }
            
        // comments
        else if self.currentPath == "/rss/channel/item/comments" {
            self.currentFeedItem?.feedCommentsURL = self.currentElementContent
        }
        
        // enclosures (RSS items only)
        else if self.currentPath == "/rss/channel/item/enclosure" {
            let type:String? = self.currentElementAttributes?["type"] as? String
            let content: String? = self.currentElementAttributes?["url"] as? String
            let length:Int? = Int((self.currentElementAttributes?["length"] as? String)!)
            if content != nil && type != nil && length != nil {
                let feedEnclosure = FeedEnclosure(url: content!, type: type!, length: length!)
                self.currentFeedItem?.feedEnclosures.append(feedEnclosure)
            }
        }
            
        // category
        else if self.currentPath == "/rss/channel/category" {
            self.currentFeedChannel?.channelCategory = self.currentElementContent
        }
        else if self.currentPath == "/rss/channel/item/category" {
            self.currentFeedItem?.feedCategories.append(self.currentElementContent)
        }
            
        // author (feeds only)
        else if self.currentPath == "/rss/channel/item/author" || self.currentPath == "/rss/channel/item/dc:creator" {
            self.currentFeedItem?.feedAuthor = self.currentElementContent
        }
            
        // GUID / Identifier
        else if self.currentPath == "/rss/channel/item/guid" {
            self.currentFeedItem?.feedIdentifier = self.currentElementContent
        }
        
        // clear elements
        self.currentElementAttributes = nil
        self.currentElementIdentifier = nil
        self.currentElementContent = nil
        
        self.currentPath = (NSURL(fileURLWithPath: self.currentPath).URLByDeletingLastPathComponent?.path)!
    }
    
    func parseEndOfRSS1Element(elementName: String, qualifiedName qName: String!) {
        // channel (only for RSS1)
        if (qName == "/rdf:RDF/channel" && self.feedType == .RSS1) {
            if (self.currentFeedChannel?.isValid == true) {
                self.delegate?.feedParser?(self, didParseChannel: self.currentFeedChannel)
            }
            self.currentFeedChannel = nil
        }
            
        // item
        else if self.currentPath == "/rdf:RDF/item" {
            if (self.currentFeedItem?.isValid == true) {
                self.delegate?.feedParser?(self, didParseItem: self.currentFeedItem)
            }
            self.currentFeedItem = nil
            
            // check for max items
            self.feedItemsParsed++
            if (self.feedItemsParsed >= self.maxFeedsToParse) { // parse up to maxFeedsToParse
                self.successfullyCloseParsingAfterMaxItemsFound()
            }
        }
            
        // title
        else if self.currentPath == "/rdf:RDF/channel/title" {
            self.currentFeedChannel?.channelTitle = self.currentElementContent
        }
        else if self.currentPath == "/rdf:RDF/item/title" {
            self.currentFeedItem?.feedTitle = self.currentElementContent
        }
            
        // link
        else if self.currentPath == "/rdf:RDF/channel/link" {
            self.currentFeedChannel?.channelLink = self.currentElementContent
        }
        else if self.currentPath == "/rdf:RDF/item/link" {
            self.currentFeedItem?.feedLink = self.currentElementContent
        }
            
        // description -- content
        else if self.currentPath ==  "/rdf:RDF/channel/description" || self.currentPath == "/rdf:RDF/channel/dc:description" {
            self.currentFeedChannel?.channelDescription = self.currentElementContent
        }
        else if self.currentPath == "/rdf:RDF/item/description" || self.currentPath == "/rdf:RDF/item/dc:description" {
            self.currentFeedItem?.feedContent = self.currentElementContent
        }
            
        // pub date
        else if self.currentPath == "/rdf:RDF/channel/dc:date" {
            self.currentFeedChannel?.channelDateOfLastChange = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
        else if self.currentPath == "/rdf:RDF/item/dc:date" {
            self.currentFeedItem?.feedPubDate = self.retrieveDateFromDateString(self.currentElementContent, feedType: self.feedType)
        }
            
        // language (channels only)
        else if self.currentPath == "/rdf:RDF/channel/dc:language" {
            self.currentFeedChannel?.channelLanguage = self.currentElementContent
        }
        
        // enclosures (RSS items only)
        else if self.currentPath == "/rdf:RDF/item/enc:enclosure" {
            let type:String? = self.currentElementAttributes?["type"] as? String
            let content: String? = self.currentElementAttributes?["url"] as? String
            let length:Int? = Int((self.currentElementAttributes?["length"] as? String)!)
            if content != nil && type != nil && length != nil {
                let feedEnclosure = FeedEnclosure(url: content!, type: type!, length: length!)
                self.currentFeedItem?.feedEnclosures.append(feedEnclosure)
            }
        }
            
        // category
        else if self.currentPath == "/rdf:RDF/channel/dc:category" {
            if (self.feedType == .Atom) { self.currentFeedChannel?.channelCategory = self.currentElementAttributes?["term"] as? String }
            else { self.currentFeedChannel?.channelCategory = self.currentElementContent }
        }
        else if self.currentPath == "/rdf:RDF/channel/dc:category" {
            self.currentFeedItem?.feedCategories.append(self.currentElementContent)
        }
            
        // author (feeds only)
        else if self.currentPath == "/rdf:RDF/item/dc:creator" {
            self.currentFeedItem?.feedAuthor = self.currentElementContent
        }
            
        // GUID / Identifier
        else if self.currentPath == "/rdf:RDF/item/dc:identifier" {
            self.currentFeedItem?.feedIdentifier = self.currentElementContent
        }
        
        // clear elements
        self.currentElementAttributes = nil
        self.currentElementIdentifier = nil
        self.currentElementContent = nil
        
        self.currentPath = (NSURL(fileURLWithPath: self.currentPath).URLByDeletingLastPathComponent?.path)!
    }
    
    // MARK: - Characters and CDATA blocks, other parsing methods
    
    func parser(parser: NSXMLParser, foundCDATA CDATABlock: NSData) {
        var string: String? = String(data: CDATABlock, encoding: NSUTF8StringEncoding)
        if (string == nil) { string = String (data: CDATABlock, encoding: NSISOLatin1StringEncoding) }
        if (string == nil) { string = "" }
        
        self.currentElementContent = self.currentElementContent != nil ? self.currentElementContent + string! : string!
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        self.currentElementContent = self.currentElementContent != nil ? self.currentElementContent + string : string
    }

    func parserDidEndDocument(parser: NSXMLParser) {
        self.delegate?.feedParser?(self, successfullyParsedURL: feedURL)
    }
    
    // MARK: - Utility methods
    
    func parseAtomLink(qualifiedName: NSString, attributes: [NSObject: AnyObject]?, content: String?) -> Void {
        let rel: String? = attributes?["rel"] as? String
        
        // channel link:
        if (qualifiedName == "/feed/link") {
            if (attributes?["href"] != nil) && (rel == nil || rel == "alternate") {
                self.currentFeedChannel?.channelLink = attributes?["href"] as? String
            }
            return;
        }

        // item link:
        if (qualifiedName == "/feed/entry/link") {
            if (rel == nil) { // feed item link
                self.currentFeedItem?.feedLink = attributes?["href"] as? String
            }
            else if (rel == "enclosure") {
                // generate a new enclosure and add it to the current feed item.
                let type:String? = attributes?["type"] as? String
                let length:Int? = Int((attributes?["length"] as? String)!)
                if content != nil && type != nil && length != nil {
                    let feedEnclosure = FeedEnclosure(url: content!, type: type!, length: length!)
                    self.currentFeedItem?.feedEnclosures.append(feedEnclosure)
                }

            }
            return;
        }
    }
    
    func retrieveDateFromDateString(dateString: String, feedType: FeedType?) -> NSDate {
        // extract date object from string
        let currentDateFormat: DateFormat? = feedType?.feedsDateFormat()
        var currentDate: NSDate! = NSDate(fromString: dateString, format: currentDateFormat ?? .RFC822)
        // if we were unable to extract a proper date, try with other possible formats and fallback to current date.
        if currentDate == nil { currentDate = NSDate(fromString: dateString, format: .IncompleteRFC822) }
        if currentDate == nil { currentDate = NSDate(fromString: dateString, format: .ISO8601) }
        if currentDate == nil { currentDate = NSDate() }
        
        return currentDate
    }
    
    func successfullyCloseParsingAndReturnJustChannel(feedChannel: FeedChannel) -> Void {
        feedParser?.abortParsing()
        delegate?.feedParser?(self, didParseChannel: feedChannel)
        parsingStatus = .Succeed
        delegate?.feedParser?(self, successfullyParsedURL: feedURL)
    }
    
    func successfullyCloseParsingAfterMaxItemsFound() -> Void {
        feedParser?.abortParsing()
        parsingStatus = .Succeed
        delegate?.feedParser?(self, successfullyParsedURL: feedURL)
    }
    
    func abortParsingAndReportFailure(reason: String) {
        feedParser?.abortParsing()
        parsingStatus = .Failed
        delegate?.feedParser?(self, parsingFailedReason: reason)
    }
    
    func encodingTypeFromString(textEncodingName: String?) -> NSStringEncoding? {
        if textEncodingName == nil { return nil; }
        
        let cfEncoding: CFStringEncoding = CFStringConvertIANACharSetNameToEncoding(textEncodingName! as NSString as CFStringRef)
        if cfEncoding != kCFStringEncodingInvalidId { return CFStringConvertEncodingToNSStringEncoding(cfEncoding); }
        else { return nil; }
    }
    
}
