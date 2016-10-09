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
        r = (s as NSString).range(of: pattern, options: NSString.CompareOptions.regularExpression)
        while (r.location != NSNotFound) {
            s = (s as NSString).replacingCharacters(in: r, with: " ")
            r = (s as NSString).range(of: pattern, options: NSString.CompareOptions.regularExpression)
        }
        return s.replacingOccurrences(of: "  ", with: " ")
    }
    
    func stringByDecodingHTMLEscapeCharacters() -> String {
        var s = self.replacingOccurrences(of: "&quot;", with: "\"")
        s = s.replacingOccurrences(of: "&apos;", with: "'")
        s = s.replacingOccurrences(of: "&amp;", with: "&")
        s = s.replacingOccurrences(of: "&lt;", with: "<")
        s = s.replacingOccurrences(of: "&gt;", with: ">")
        s = s.replacingOccurrences(of: "&#39;", with: "'")
        s = s.replacingOccurrences(of: "&ldquot;", with: "\"")
        s = s.replacingOccurrences(of: "&rdquot;", with: "\"")
        s = s.replacingOccurrences(of: "&nbsp;", with: " ")
        s = s.replacingOccurrences(of: "&aacute;", with: "á")
        s = s.replacingOccurrences(of: "&eacute;", with: "é")
        s = s.replacingOccurrences(of: "&iacute;", with: "í")
        s = s.replacingOccurrences(of: "&oacute;", with: "ó")
        s = s.replacingOccurrences(of: "&uacute;", with: "ú")
        s = s.replacingOccurrences(of: "&ntilde;", with: "ñ")
        s = s.replacingOccurrences(of: "&#8217;", with: "'")

        return s
    }
}
