//
//  String+FeedElementIdentification.swift
//
//  Created by Nacho on 5/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

extension String {
    // MARK: - Channel methods
    
    /** receives a Fully Qualified Name and returns yes if this element contains a feed channel */
    func isFeedChannel(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel" && feedType == FeedType.RSS1) ||
               (self == "/rss/channel" && feedType == FeedType.RSS2) ||
               (self == "/feed" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the pub date of a channel */
    func isFeedChannelPubDate(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/dc:date" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/lastBuildDate" && feedType == FeedType.RSS2) ||
            (self == "/feed/updated" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the title of a channel */
    func isFeedChannelTitle(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/title" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/title" && feedType == FeedType.RSS2) ||
            (self == "/feed/title" && feedType == FeedType.Atom)
    }

    /** receives a Fully Qualified Name and returns yes if this element contains the link of a channel  */
    func isFeedChannelLink(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/link" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/link" && feedType == FeedType.RSS2) ||
            (self == "/feed/link" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the description of a channel  */
    func isFeedChannelDescription(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/description" && feedType == FeedType.RSS1) ||
            (self == "/rdf:RDF/channel/dc:description" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/description" && feedType == FeedType.RSS2) ||
            (self == "/feed/description" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the language of a channel  */
    func isFeedChannelLanguage(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/dc:language" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/language" && feedType == FeedType.RSS2)
    }

    /** receives a Fully Qualified Name and returns yes if this element contains the category of a channel  */
    func isFeedChannelCategory(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/channel/dc:category" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/category" && feedType == FeedType.RSS2)
    }
    

    // MARK: - Item methods
    
    /** receives a Fully Qualified Name and returns yes if this element contains the content of a feed */
    func isFeedItemDescription(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/description" && feedType == FeedType.RSS1) ||
            (self == "/rdf:RDF/item/dc:description" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/description" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/content" && feedType == FeedType.Atom)
    }
    
    
    /** receives a Fully Qualified Name and returns yes if this element contains the link of a feed */
    func isFeedItemLink(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/link" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/link" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/link" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the author of a feed */
    func isFeedItemAuthor(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/dc:creator" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/author" && feedType == FeedType.RSS2) ||
            (self == "/rss/channel/item/dc:creator" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/author/name" && feedType == FeedType.Atom)
    }

    /** receives a Fully Qualified Name and returns yes if this element contains the title of a item */
    func isFeedItemTitle(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/title" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/title" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/title" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the pub date of a feed item */
    func isFeedItemPubDate(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/dc:date" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/pubDate" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/updated" && feedType == FeedType.Atom)
    }

    /** receives a Fully Qualified Name and returns yes if this element contains a feed item */
    func isFeedItem(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the category of a feed item  */
    func isFeedItemCategory(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/dc:category" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/category" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/category" && feedType == FeedType.Atom)
    }
    
    /** receives a Fully Qualified Name and returns yes if this element contains the comments URL of a feed item  */
    func isFeedItemComments(feedType: FeedType!) -> Bool {
        return (self == "/rss/channel/item/comments" && feedType == FeedType.RSS2)
    }

    /** receives a Fully Qualified Name and returns yes if this element contains a Enclosure for a feed item  */
    func isFeedItemEnclosure(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/enc:enclosure" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/enclosure" && feedType == FeedType.RSS2)
    }
    
    
    /** receives a Fully Qualified Name and returns yes if this element contains the identifier of a feed item  */
    func isFeedItemIdentifier(feedType: FeedType!) -> Bool {
        return (self == "/rdf:RDF/item/dc:identifier" && feedType == FeedType.RSS1) ||
            (self == "/rss/channel/item/guid" && feedType == FeedType.RSS2) ||
            (self == "/feed/entry/id" && feedType == FeedType.Atom)
    }

}













