//
//  ViewController.swift
//  FeedParser
//
//  Created by Nacho on 13/12/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

let kFeedParserExampleFeedSourceURL = "http://digitalleaves.com/blog/feed/"

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FeedParserDelegate {

    // Outlets & Controls
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // entries and parser
    var parser: FeedParser?
    var entries: [FeedItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialization
        entries = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = true
        searchBar.text = kFeedParserExampleFeedSourceURL
        loadingLabel.text = "Enter a feed URL to load contents"
    }

    // MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text?.characters.count < 1 { return }
        self.searchBar.resignFirstResponder()
        self.tableView.hidden =  true
        
        self.entries = []
        self.loadingLabel.text = "Loading entries from \(searchBar.text)"
        self.loadingLabel.hidden = false
        // start parsing feed
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.parser = FeedParser(feedURL: self.searchBar.text!)
            self.parser?.delegate = self
            self.parser?.parse()
        })
    }
    
    // MARK: - UITableViewDelegate/DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FeedItemCell", forIndexPath: indexPath) as UITableViewCell
        let item = entries![indexPath.row]
        
        // image
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if item.mainImage != nil {
                imageView.image = item.mainImage
            } else {
                if item.imageURLsFromDescription == nil || item.imageURLsFromDescription?.count == 0  {
                    item.mainImage = UIImage(named: "roundedDefaultFeed")
                    imageView.image = item.mainImage
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    for imageURLString in item.imageURLsFromDescription! {
                        if let image = self.loadImageSynchronouslyFromURLString(imageURLString) {
                            item.mainImage = image
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                imageView.image = image
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            })
                            break;
                        }
                    }
                })
            }
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame) / 2.0
            imageView.clipsToBounds = true
        }
        
        // title
        if let titleLabel = cell.viewWithTag(2) as? UILabel {
            titleLabel.text = item.feedTitle ?? "Untitled feed"
        }
        
        // subtitle
        if let subtitleLabel = cell.viewWithTag(3) as? UILabel {
            subtitleLabel.text = item.feedContentSnippet ?? item.feedContent?.stringByDecodingHTMLEntities() ?? ""
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let feedItem = entries?[indexPath.row] {
            if let url = NSURL(string: feedItem.feedLink ?? "") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
    }
    
    // MARK: - FeedParserDelegate methods
    
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parser did parse channel \(channel)")
        })
    }
    
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parser did parse item \(item.feedTitle)")
            self.entries?.append(item)
        })
    }
    
    func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.entries?.count > 0) {
                print("All feeds parsed.")
                self.tableView.hidden = false
                self.loadingLabel.hidden = true
                self.tableView.reloadData()
            } else {
                print("No feeds found at url \(url).")
                self.tableView.hidden = true
                self.loadingLabel.hidden = false
                self.loadingLabel.text = "No feeds found at url \(url)."
            }
        })
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parsed failed: \(reason)")
            self.entries = []
            self.tableView.hidden = true
            self.loadingLabel.text = "Failed to retrieve feeds from \(self.parser!.feedURL)"
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        print("Feed parsing aborted by the user")
        self.entries = []
        self.tableView.hidden = true
        self.loadingLabel.text = "Feed loading cancelled by the user."
    }

    // MARK: - Network methods
    func loadImageSynchronouslyFromURLString(urlString: String) -> UIImage? {
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(URL: url)
            request.timeoutInterval = 30.0
            var response: NSURLResponse?
            let error: NSErrorPointer = nil
            var data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            } catch let error1 as NSError {
                error.memory = error1
                data = nil
            }
            if (data != nil) {
                return UIImage(data: data!)
            }
        }
        return nil
    }
    
}

