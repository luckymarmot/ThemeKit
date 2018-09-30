//
//  GradientView.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa
import ThemeKit

class TitleView: NSView, NSTextFieldDelegate {

    /// Our text field
    @IBOutlet weak var titleTextField: NSTextField!

    /// Weak reference to selected Note
    @objc weak var note: Note?

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
            let obj = notification.object
            if let viewController = obj as? NSViewController,
                viewController.view.window == self.window,
                let note = notification.userInfo?["note"] as? Note {

                self.note = note
                self.titleTextField.stringValue = note.title
            }
        }

        // Observe note title change notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteTitle, object: nil, queue: nil) { (_) in
            if let note = self.note {
                self.titleTextField.stringValue = note.title
            }
        }
    }

    /// Drawing code
    override func draw(_ dirtyRect: NSRect) {
        guard note?.title != nil else {
            return
        }

        // Fill with content background
        ThemeColor.contentBackgroundColor.set()
        NSBezierPath(rect: bounds).fill()

        // Draw gradient
        let gradientFrame = NSRect(x: 4, y: 0, width: bounds.width - 8, height: 4)
        if let gradient = ThemeGradient.rainbowGradient {
            gradient.draw(in: gradientFrame, angle: 0)
        }

    }

    // MARK: -
    // MARK: NSTextDelegate

    func controlTextDidChange(_ obj: Notification) {
        guard let note = self.note else {
            return
        }
        note.title = titleTextField.stringValue
        note.lastModified = Date()
        NotificationCenter.default.post(name: .didEditNoteTitle, object: self, userInfo: ["note": note])
    }

}
