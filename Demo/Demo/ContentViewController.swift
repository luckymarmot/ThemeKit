//
//  ContentViewController.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class ContentViewController: NSViewController, NSTextDelegate {
    
    /// Our content view
    @IBOutlet var contentView: NSView!
    
    /// Our text view
    @IBOutlet var contentTextView: NSTextView!
    
    /// Our placeholder view when no note is selected.
    @IBOutlet var noSelectionPlaceholder: NSView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup our Text View
        contentTextView.textColor = ThemeColor.contentTextColor
        contentTextView.backgroundColor = ThemeColor.contentBackgroundColor
        contentTextView.drawsBackground = true
        contentTextView.textContainer?.lineFragmentPadding = 16
        var font = NSFont(name: "GillSans-Light", size: 16)
        if font == nil {
            font = NSFont.systemFont(ofSize: 14)
        }
        contentTextView.font = font
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.4
        contentTextView.defaultParagraphStyle = paragraphStyle
        
        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if obj is NSViewController && (obj as! NSViewController).view.window == self.view.window {
                self.representedObject = notification.userInfo?["note"]
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            var subview: NSView
            
            if let note = representedObject as? Note {
                contentTextView.string = note.text
                contentTextView.scrollToBeginningOfDocument(self)
                noSelectionPlaceholder.removeFromSuperview()
                subview = contentView
            }
            else {
                contentTextView.string = ""
                contentView.removeFromSuperview()
                subview = noSelectionPlaceholder
            }
            
            self.view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = true
            subview.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
            subview.frame = view.bounds
        }
    }    
    
    // MARK: -
    // MARK: NSTextDelegate
    
    public func textDidChange(_ notification: Notification) {
        if let note = representedObject as? Note {
            note.text = contentTextView.string!
            note.lastModified = Date()
            NotificationCenter.default.post(name: .didEditNoteText, object: self, userInfo: ["note": note])
        }
    }
    
}
