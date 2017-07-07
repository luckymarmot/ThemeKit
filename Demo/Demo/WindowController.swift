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
        
        // Observe theme change notifications
        NotificationCenter.default.addObserver(forName: .didChangeTheme, object: nil, queue: nil) { (notification) in
            // update KVO property
            self.willChangeValue(forKey: "canEditTheme")
            self.didChangeValue(forKey: "canEditTheme")
            
            // update window color
            self.updateWindowTitleBarColor()
        }
        
        // Allow window titlebar theming
        // Done on code for illustrative purposes (can be set on IB).
        if let window = super.window {
            window.styleMask.formUnion(.texturedBackground)
            window.invalidateShadow()
        }
        
        // HACK: Observe windows update so that we can force-apply a theme when a new
        // window/tab is added. This is a workaround for a refresh issue occurring
        // when attempting to theme the window (as in `updateWindowTitleBarColor()`),
        // and should not be needed on normal cases.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowDidUpdate, object: nil, queue: nil) { (notification) in
            let newWindowCount = NSApplication.shared().windows.filter { $0.title != "" }.count
            if WindowController.windowCount != newWindowCount {
                WindowController.windowCount = newWindowCount
                ThemeManager.shared.reApplyCurrentTheme()
            }
        }
    }
    
    /// Private reference of number of windows.
    private static var windowCount = NSApplication.shared().windows.filter { $0.title != "" }.count
    
    /// Update window title with current note title.
    func updateTitle(_ note: Note) {
        self.window?.title = "\(note.title) - ThemeKit Demo"
    }
    
    /// Update window titlebar color.
    func updateWindowTitleBarColor() {
        guard let window = super.window else {
            return
        }
        
        if let windowTitleBarColor = themeKit.theme.themeAsset?("windowTitleBarColor") as? NSColor {
            // enable window theming
            window.styleMask.formUnion(.texturedBackground)
            window.backgroundColor = windowTitleBarColor
            window.alphaValue = 0.9
            window.alphaValue = 1.0
        }
        else {
            // disable window theming
            window.styleMask.subtract(.texturedBackground)
            window.backgroundColor = nil
            window.alphaValue = 0.9
            window.alphaValue = 1.0
        }
    }
    
    /// Can edit current theme (must be a `UserTheme`).
    var canEditTheme: Bool {
        return ThemeManager.shared.theme.isUserTheme
    }
    
    /// Edit current (`UserTheme`) theme.
    @IBAction func editTheme(_ sender: Any) {
        if ThemeManager.shared.theme.isUserTheme,
            let userTheme = ThemeManager.shared.theme as? UserTheme,
            let userThemeURL = userTheme.fileURL {
            NSWorkspace.shared().open(userThemeURL)
        }
    }
    
}
