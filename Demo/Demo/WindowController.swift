//
//  WindowController.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class WindowController: NSWindowController {
    
    public var themeKit: ThemeManager = ThemeManager.shared
    
    override func windowDidLoad() {
        // Observe note selection change notifications
        NotificationCenter.default.addObserver(forName: .didChangeNoteSelection, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if let note = notification.userInfo?["note"] as? Note,
                let viewController = obj as? NSViewController,
                viewController.view.window == self.window {
                self.updateTitle(note)
            }
        }
        
        // Observe note text edit notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteText, object: nil, queue: nil) { (notification) in
            let obj = notification.object
            if let note = notification.userInfo?["note"] as? Note,
                let viewController = obj as? NSViewController,
                viewController.view.window == self.window {
                self.updateTitle(note)
            }
        }
    }
    
    func updateTitle(_ note: Note) {
        self.window?.title = "\(note.title) - ThemeKit Demo"
    }
}
