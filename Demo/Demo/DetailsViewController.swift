//
//  DetailsViewController.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class DetailsViewController: NSViewController {
    
    // IBOutlets
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var detailsTitleTxt: NSTextField!
    @IBOutlet weak var wordCountTxt: NSTextField!
    @IBOutlet weak var characterCount: NSTextField!
    @IBOutlet weak var lastModifiedTxt: NSTextField!
    @IBOutlet weak var deleteButton: NSButton!
    
    var dateFormatter: DateFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup colors
        detailsTitleTxt.textColor = ThemeColor.detailsTitleColor
        
        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .medium
        dateFormatter?.timeStyle = .none
        
        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            self.representedObject = notification.userInfo?["note"];
        }
        
        // Observe note text edit notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteText, object: nil, queue: nil) { (notification) in
            self.representedObject = notification.userInfo?["note"];
        }
    }
    
    override var representedObject: Any? {
        didSet {
            if let note = representedObject as? Note {
                containerView.isHidden = false
                deleteButton.isHidden = false
                wordCountTxt.stringValue = String(note.textWordCount)
                characterCount.stringValue = String(note.textCharacterCount)
                lastModifiedTxt.stringValue = dateFormatter?.string(from: note.lastModified) ?? "-"
            }
            else {
                containerView.isHidden = true
                deleteButton.isHidden = true
            }
        }
    }
    
}
