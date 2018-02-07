//
//  ContentViewController.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
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

        // Setup our clipping view background color (text view parent)
        if let clipView = contentTextView.enclosingScrollView?.contentView {
            clipView.backgroundColor = ThemeColor.contentBackgroundColor
            clipView.drawsBackground = true
        }

        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if let viewController = obj as? NSViewController,
                viewController.view.window == self.view.window {
                self.representedObject = notification.userInfo?["note"]
            }
        }

        // Fix white scrollbar view when in dark theme and scrollbars are set to
        // always be shown on *System Preferences > General*.
        if let scrollView = contentTextView.enclosingScrollView {
            scrollView.backgroundColor = ThemeColor.contentBackgroundColor
            scrollView.wantsLayer = true
        }

        // Observe theme changes
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme(_:)), name: .didChangeTheme, object: nil)
    }

    override var representedObject: Any? {
        didSet {
            var subview: NSView

            if let note = representedObject as? Note {
                contentTextView.string = note.text
                contentTextView.scrollToBeginningOfDocument(self)
                noSelectionPlaceholder.removeFromSuperview()
                subview = contentView
            } else {
                contentTextView.string = ""
                contentView.removeFromSuperview()
                subview = noSelectionPlaceholder
            }

            self.view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = true
            subview.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
            subview.frame = view.bounds
        }
    }

    // MARK: -
    // MARK: Theme related

    @objc private func didChangeTheme(_ notification: Notification? = nil) {
        // Update `NSScroller` background color based on current theme
        DispatchQueue.main.async {
            self.contentTextView.enclosingScrollView?.verticalScroller?.layer?.backgroundColor = ThemeColor.contentBackgroundColor.cgColor
        }

        // If in fullscreen, need to re-focus current window
        if let window = view.window {
            let isWindowInFullScreen = window.styleMask.contains(NSWindow.StyleMask.fullScreen) || window.className == "NSToolbarFullScreenWindow"
            if isWindowInFullScreen {
                DispatchQueue.main.async {
                    window.makeKey()
                }
            }
        }
    }

    // MARK: -
    // MARK: NSTextDelegate

    public func textDidChange(_ notification: Notification) {
        if let note = representedObject as? Note {
            note.text = contentTextView.string
            note.lastModified = Date()
            NotificationCenter.default.post(name: .didEditNoteText, object: self, userInfo: ["note": note])
        }
    }

}
