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
    @IBOutlet weak var contentTextView: NSTextView!
    
    /// Our placeholder view when no note is selected.
    @IBOutlet var noSelectionPlaceholder: NSView!
    
    /// Our contentView scrollview.
    @IBOutlet var contentScrollView: NSScrollView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup our Text View
        contentTextView.textColor = ThemeColor.contentTextColor
        contentTextView.backgroundColor = ThemeColor.contentBackgroundColor
        contentTextView.drawsBackground = true
        contentTextView.font = NSFont.userFixedPitchFont(ofSize: 11)
        
        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            self.representedObject = notification.userInfo?["note"];
        }
    }
    
    override var representedObject: Any? {
        didSet {
            var subview: NSView
            
            if let note = representedObject as? Note {
                contentTextView.string = note.text
                contentTextView.scrollToBeginningOfDocument(self)
                noSelectionPlaceholder.removeFromSuperview()
                subview = contentScrollView
            }
            else {
                contentTextView.string = ""
                contentScrollView.removeFromSuperview()
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
        }
    }
    
}
