//
//  GradientView.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class TitleView: NSView, NSTextFieldDelegate {
    
    /// Our text field
    @IBOutlet weak var titleTextField: NSTextField!
    
    /// Weak reference to selected Note
    weak var note: Note?
    
    override func awakeFromNib() {
        // Setup title text
        titleTextField.textColor = ThemeColor.contentTitleColor
        titleTextField.backgroundColor = ThemeColor.contentBackgroundColor
        titleTextField.drawsBackground = true
        titleTextField.delegate = self
        var font = NSFont(name: "GillSans-Light", size: 24)
        if font == nil {
            font = NSFont.systemFont(ofSize: 24)
        }
        titleTextField.font = font
        
        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            self.note = notification.userInfo?["note"] as? Note;
            
            if self.note != nil {
                self.titleTextField.stringValue = (self.note?.title)!
            }
        }
        
        // Observe note title change notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteTitle, object: nil, queue: nil) { (notification) in
            if self.note != nil {
                self.titleTextField.stringValue = (self.note?.title)!
            }
        }
    }
    
    /// Drawing code
    override func draw(_ dirtyRect: NSRect) {
        guard note?.title != nil else { return }
        
        // Fill with content background
        ThemeColor.contentBackgroundColor.set()
        NSBezierPath(rect: bounds).fill()
        
        // Draw gradient
        let gradientFrame = NSMakeRect(4, 0, NSWidth(bounds) - 8, 4)
        ThemeGradient.rainbowGradient.draw(in: gradientFrame, angle: 0)
        
    }
    
    
    // MARK: -
    // MARK: NSTextDelegate
    
    override func controlTextDidChange(_ obj: Notification) {
        note?.title = titleTextField.stringValue
        note?.lastModified = Date()
        NotificationCenter.default.post(name: .didEditNoteTitle, object: self, userInfo: ["note" : note])
    }
    
}
