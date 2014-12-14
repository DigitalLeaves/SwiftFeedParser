//
//  String+RemoveHTMLCharacters.swift
//
//  Created by Nacho on 29/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /**
     * A pretty basic and simple decoder that will change the HTML entities for UTF8 ready characters.
     */
    func stringByDecodingHTMLEntities() -> String? {
        var r: NSRange
        let pattern = "<[^>]+>"
        var s = self.stringByDecodingHTMLEscapeCharacters()
        r = (s as NSString).rangeOfString(pattern, options: NSStringCompareOptions.RegularExpressionSearch)
        while (r.location != NSNotFound) {
            s = (s as NSString).stringByReplacingCharactersInRange(r, withString: " ")
            r = (s as NSString).rangeOfString(pattern, options: NSStringCompareOptions.RegularExpressionSearch)
        }
        return s.stringByReplacingOccurrencesOfString("  ", withString: " ")
    }
    
    func stringByDecodingHTMLEscapeCharacters() -> String {
        var s = self.stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&apos;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        s = s.stringByReplacingOccurrencesOfString("&lt;", withString: "<")
        s = s.stringByReplacingOccurrencesOfString("&gt;", withString: ">")
        s = s.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&ldquot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&rdquot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
        s = s.stringByReplacingOccurrencesOfString("&aacute;", withString: "á")
        s = s.stringByReplacingOccurrencesOfString("&eacute;", withString: "é")
        s = s.stringByReplacingOccurrencesOfString("&iacute;", withString: "í")
        s = s.stringByReplacingOccurrencesOfString("&oacute;", withString: "ó")
        s = s.stringByReplacingOccurrencesOfString("&uacute;", withString: "ú")
        s = s.stringByReplacingOccurrencesOfString("&ntilde;", withString: "ñ")
        s = s.stringByReplacingOccurrencesOfString("&#8217;", withString: "'")

        return s
    }
}