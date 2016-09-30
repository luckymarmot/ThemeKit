//
//  Note.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/// Our basic Note class.
class Note: NSObject, NSCoding {
    
    /// Note title.
    var title: String
    
    /// Note text.
    var text: String
    
    /// Last modified date.
    var lastModified: Date
    
    // Character count.
    var textCharacterCount: Int {
        return text.characters.count
    }
    
    // Word count.
    var textWordCount: Int {
        return text.components(separatedBy: " ").count
    }
    
    /// Initializer
    init(title: String = "Untitled Note", text: String = "") {
        self.title = title
        self.text = text
        self.lastModified = Date()
    }
    
    
    // MARK: -
    // MARK: NSCoder
    
    public func encode(with aCoder: NSCoder) {
        //[encoder encodeObject:title forKey:@"Title"];
        aCoder.encode(title, forKey: "title")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(lastModified, forKey: "lastModified")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        text = aDecoder.decodeObject(forKey: "text") as! String
        lastModified = aDecoder.decodeObject(forKey: "lastModified") as! Date
    }
    
}
