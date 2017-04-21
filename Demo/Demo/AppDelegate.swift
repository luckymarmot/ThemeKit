//
//  AppDelegate.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK:-
    // MARK: App Launch
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        /* 1. Simpler usage: switch between light and dark theme directly. */
        
        //ThemeManager.lightTheme.apply()
        //ThemeManager.darkTheme.apply()
        //ThemeManager.systemTheme.apply()
        
        
        /* 2. Advanced usage: define window theme policy & enable user themes.
         * Themes will be selected using popup bound to user defaults. */
        
        // 2.1 Setup window theme policy
        ThemeManager.shared.windowThemePolicy = .themeAllWindows
        //ThemeManager.shared.windowThemePolicy = .themeSomeWindows(windowClasses: [MyCustomWindow.self])
        //ThemeManager.shared.windowThemePolicy = .doNotThemeSomeWindows(windowClasses: [NSPanel.self])
        //ThemeManager.shared.windowThemePolicy = .doNotThemeWindows
        
        // 2.2 User themes folder
        let workingDirectory = FileManager.default.currentDirectoryPath
        if workingDirectory != "/" {
            // probably launching from Xcode, point to project `Themes` folder so
            // users can easily test the live editing of `.theme` files
            let projectRootURL = URL(fileURLWithPath: workingDirectory, isDirectory: true).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Themes")
            ThemeManager.shared.userThemesFolderURL = projectRootURL
        }
        else if let bundleResourcePath = Bundle.main.resourcePath {
            // otherwise, just point to the bundled Resources folder
            ThemeManager.shared.userThemesFolderURL = URL(fileURLWithPath: bundleResourcePath)
        }
        // let users know about our choosen user themes folder
        if let userThemesFolderURL = ThemeManager.shared.userThemesFolderURL {
            NSLog("ThemeManager.shared.userThemesFolderURL: %@", userThemesFolderURL.path)
        }
        
        // 2.3 You can define the default light and dark theme, used for `ThemeManager.systemTheme`
        //ThemeManager.lightTheme = ThemeManager.shared.theme(withIdentifier: PaperTheme.identifier)!
        //ThemeManager.darkTheme = ThemeManager.shared.theme(withIdentifier: "com.luckymarmot.ThemeKit.PurpleGreen")!
        
        // 2.4 Set default theme (default: macOS theme `ThemeManager.systemTheme`)
        ThemeManager.defaultTheme = ThemeManager.lightTheme
        
        // 2.5 Apply last applied theme, or the default one
        ThemeManager.shared.applyLastOrDefaultTheme()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Watch for theme changes and update Theme menu
        NotificationCenter.default.addObserver(self, selector: #selector(updateThemeMenu(_:)), name: .didChangeTheme, object: nil)
        
        // Build theme menu
        updateThemeMenu()
    }
    
    
    // MARK:-
    // MARK: Theme related
    
    @objc private func updateThemeMenu(_ notification: Notification? = nil) {
        // Clean menu
        themeMenu.removeAllItems()
        
        // Add themes
        var counter = 1
        for theme in ThemeManager.shared.themes {
            let item = NSMenuItem(title: theme.shortDisplayName, action: #selector(switchTheme(_:)), keyEquivalent: String(counter))
            item.representedObject = theme
            item.state = (ThemeManager.shared.theme.identifier == theme.identifier) ? NSOnState : NSOffState
            themeMenu.addItem(item)
            counter += 1
        }
    }
    
    @IBAction func switchTheme(_ menuItem: NSMenuItem) {
        guard menuItem.representedObject != nil else { return }
        
        if let theme = menuItem.representedObject as? Theme {
            ThemeManager.shared.theme = theme
            updateThemeMenu()
        }
    }
    
    
    // MARK:-
    // MARK: App Termination
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    // MARK:-
    // MARK: Tabs
    
    private var tabs: [NSWindowController] = []
    
    @IBAction func newWindowForTab(_ sender: Any?) {
        let storyBoard = NSStoryboard(name: "Main", bundle:nil)
        if let windowController = storyBoard.instantiateController(withIdentifier: "WindowController") as? NSWindowController {
            windowController.showWindow(self)
        }
    }
    
    
    // MARK:-
    // MARK: Notes actions
    
    @IBAction func addNote(_ sender: NSButton) {
        sidebarViewController?.addNote(sender)
    }
    
    @IBAction func deleteNote(_ sender: NSButton) {
        sidebarViewController?.deleteNote(sender)
    }
    
    @IBAction func resetNotes(_ sender: Any) {
        sidebarViewController?.resetNotes(sender)
    }
    
    
    // MARK:-
    // MARK: Others
    
    // Weak control references
    @IBOutlet weak var themeMenu: NSMenu!
    
    // Strong controllers references
    weak var sidebarViewController: SidebarViewController?

}

extension NSApplication {
    
    static var sidebarViewController: SidebarViewController {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        return appDelegate.sidebarViewController!
    }
    
}

