//
//  ViewController.swift
//  FeedParser
//
//  Created by Nacho on 13/12/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        searchBar.text = kFeedParserExampleFeedSourceURL
        loadingLabel.text = "Enter a feed URL to load contents"
    }

    // MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.characters.count < 1 { return }
        self.searchBar.resignFirstResponder()
        self.tableView.isHidden =  true
        
        self.entries = []
        self.loadingLabel.text = "Loading entries from \(searchBar.text)"
        self.loadingLabel.isHidden = false
        // start parsing feed
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
            self.parser = FeedParser(feedURL: self.searchBar.text!)
            self.parser?.delegate = self
            self.parser?.parse()
        })
    }
    
    // MARK: - UITableViewDelegate/DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath) as UITableViewCell
        let item = entries![(indexPath as NSIndexPath).row]
        
        // image
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if item.mainImage != nil {
                imageView.image = item.mainImage
            } else {
                if item.imageURLsFromDescription == nil || item.imageURLsFromDescription?.count == 0  {
                    item.mainImage = UIImage(named: "roundedDefaultFeed")
                    imageView.image = item.mainImage
                }
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
                    for imageURLString in item.imageURLsFromDescription! {
                        if let image = self.loadImageSynchronouslyFromURLString(imageURLString) {
                            item.mainImage = image
                            DispatchQueue.main.async(execute: { () -> Void in
                                imageView.image = image
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            })
                            break;
                        }
                    }
                })
            }
            imageView.layer.cornerRadius = imageView.frame.width / 2.0
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let feedItem = entries?[(indexPath as NSIndexPath).row] {
            if let url = URL(string: feedItem.feedLink ?? "") {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    // MARK: - FeedParserDelegate methods
    
    func feedParser(_ parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        DispatchQueue.main.async(execute: { () -> Void in
            print("Feed parser did parse channel \(channel)")
        })
    }
    
    func feedParser(_ parser: FeedParser, didParseItem item: FeedItem) {
        DispatchQueue.main.async(execute: { () -> Void in
            print("Feed parser did parse item \(item.feedTitle)")
            self.entries?.append(item)
        })
    }
    
    func feedParser(_ parser: FeedParser, successfullyParsedURL url: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            if (self.entries?.count > 0) {
                print("All feeds parsed.")
                self.tableView.isHidden = false
                self.loadingLabel.isHidden = true
                self.tableView.reloadData()
            } else {
                print("No feeds found at url \(url).")
                self.tableView.isHidden = true
                self.loadingLabel.isHidden = false
                self.loadingLabel.text = "No feeds found at url \(url)."
            }
        })
    }
    
    func feedParser(_ parser: FeedParser, parsingFailedReason reason: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            print("Feed parsed failed: \(reason)")
            self.entries = []
            self.tableView.isHidden = true
            self.loadingLabel.text = "Failed to retrieve feeds from \(self.parser!.feedURL)"
        })
    }
    
    func feedParserParsingAborted(_ parser: FeedParser) {
        print("Feed parsing aborted by the user")
        self.entries = []
        self.tableView.isHidden = true
        self.loadingLabel.text = "Feed loading cancelled by the user."
    }

    // MARK: - Network methods
    func loadImageSynchronouslyFromURLString(_ urlString: String) -> UIImage? {
        if let url = URL(string: urlString) {
            let request = NSMutableURLRequest(url: url)
            request.timeoutInterval = 30.0
            var response: URLResponse?
            let error: NSErrorPointer? = nil
            var data: Data?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            } catch let error1 as NSError {
                error??.pointee = error1
                data = nil
            }
            if (data != nil) {
                return UIImage(data: data!)
            }
        }
        return nil
    }
    
}

