Swift Feed Parser
=================

A Swift Feed Parser based on NSXMLParser.

![Demo/Testing UI](http://digitalleaves.com/blog/wp-content/uploads/2014/12/iOS-Simulator-Screen-Shot-14-Dec-2014-21.33.18-168x300.png)

Swift Feed Parser is a lightweight library for parsing feeds (Atom/RDF/RSS2) written in Swift. It's been used in the development of [Ready the App news reader](http://readytheapp.com). You can use it freely on your personal or commercial projects. As the library is far from perfect, if you want to contribute or have any suggestions/optimisations, feel free to collaborate.

Use
===

The project contains a simple demo/testing App. When run, it will show a basic UITableView with a UISearchBar. Just type the URL of a atom/rss/rdf feed. It will show the posts and allow you to click on any of them for visiting the page.

Integration
===========

The library user a main class called FeedParser that employs a delegate approach. For using it, you must import the following files in your project:

* FeedParser.swift
* NSDate+FeedsDate.swift
* FeedChannel.swift
* FeedItem.swift
* FeedEnclosure.swift

Additionally, you can import also the file String+RemoveHTMLCharacters.swift, which contains a rudimentary HTML-to-text translator for demo/testing purposes only (It can be greatly improved).

Your class must implement the FeedParserDelegate protocol and include a variable for the FeedParser instance. You can initialize it and start the parsing by invoking:

```
var feedParser: FeedParser?

self.parser = FeedParser(feedURL: stringForTheFeedURL)
self.parser?.delegate = self
self.parser?.parse()
```

Your class can implement the following delegate methods:

* feedParser(parser: FeedParser, didParseChannel channel: FeedChannel): invoked when the parser identifies a feed channel containing the feed source information.
* feedParser(parser: FeedParser, didParseItem item: FeedItem): invoked when the parser successfully parses a feed item.
* feedParser(parser: FeedParser, successfullyParsedURL url: String): invoked when the parser has finished parsing the source.
* feedParser(parser: FeedParser, parsingFailedReason reason: String): invoked if the parser finds an error in the parsing process (it uses localized strings for error messages).
* feedParserParsingAborted(parser: FeedParser): invoked if the user calls the abortParsing() method.

License
=======

This library is released under the MIT License.

Copyright (c) 2014 Ignacio Nieto Carvajal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

