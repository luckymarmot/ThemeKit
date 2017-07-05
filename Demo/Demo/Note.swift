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
    var title: String = ""
    
    /// Note text.
    var text: String = ""
    
    /// Last modified date.
    var lastModified: Date = Date()
    
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
        aCoder.encode(title, forKey: "title")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(lastModified, forKey: "lastModified")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let text = aDecoder.decodeObject(forKey: "text") as? String {
            self.text = text
        }
        if let lastModified = aDecoder.decodeObject(forKey: "lastModified") as? Date {
            self.lastModified = lastModified
        }
    }
    
}
