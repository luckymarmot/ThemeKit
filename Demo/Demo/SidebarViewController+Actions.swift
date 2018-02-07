//
//  NSViewController+GlobalActions.swift
//  Demo
//
//  Created by Nuno Grilo on 01/10/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa

extension NSViewController {

    @IBAction func addNote(_ sender: NSButton) {
        NSApplication.sidebarViewController?.addNote(sender)
    }

    @IBAction func deleteNote(_ sender: NSButton) {
        NSApplication.sidebarViewController?.deleteNote(sender)
    }

    @IBAction func resetNotes(_ sender: Any) {
        NSApplication.sidebarViewController?.resetNotes(sender)
    }

}

extension NSWindowController {

    @IBAction func addNote(_ sender: NSButton) {
        NSApplication.sidebarViewController?.addNote(sender)
    }

    @IBAction func deleteNote(_ sender: NSButton) {
        NSApplication.sidebarViewController?.deleteNote(sender)
    }

    @IBAction func resetNotes(_ sender: Any) {
        NSApplication.sidebarViewController?.resetNotes(sender)
    }

}
