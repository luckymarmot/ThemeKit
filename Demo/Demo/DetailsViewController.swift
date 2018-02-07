//
//  DetailsViewController.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa
import ThemeKit

class DetailsViewController: NSViewController {

    // IBOutlets
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var detailsTitleTxt: NSTextField!
    @IBOutlet weak var fakeControlsTitleTxt: NSTextField!
    @IBOutlet weak var wordCountTxt: NSTextField!
    @IBOutlet weak var characterCount: NSTextField!
    @IBOutlet weak var lastModifiedTxt: NSTextField!

    @objc var dateFormatter: DateFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup colors
        detailsTitleTxt.textColor = ThemeColor.detailsTitleColor
        fakeControlsTitleTxt.textColor = ThemeColor.detailsTitleColor

        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .medium
        dateFormatter?.timeStyle = .none

        // Hide stuff until we have a selected note
        containerView.isHidden = true

        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if let viewController = obj as? NSViewController,
                viewController.view.window == self.view.window {
                self.representedObject = notification.userInfo?["note"]
            }
        }

        // Observe note text edit notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteText, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if let viewController = obj as? NSViewController,
                viewController.view.window == self.view.window {
                self.representedObject = notification.userInfo?["note"]
            }
        }
    }

    override var representedObject: Any? {
        didSet {
            if let note = representedObject as? Note {
                containerView.isHidden = false
                wordCountTxt.stringValue = String(note.textWordCount)
                characterCount.stringValue = String(note.textCharacterCount)
                lastModifiedTxt.stringValue = dateFormatter?.string(from: note.lastModified) ?? "-"
            } else {
                containerView.isHidden = true
            }
        }
    }

}
