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

    @IBOutlet weak var themeMenu: NSMenu!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        /* 1. Simpler usage: switch between light and dark theme directly. */
        
        //ThemeKit.lightTheme.apply()
        //ThemeKit.darkTheme.apply()
        //ThemeKit.systemTheme.apply()
        
        
        /* 2. Advanced usage: define window theme policy & enable user themes.
         * Themes will be selected using popup bound to user defaults. */
        
        // 2.1 Setup window theme policy
        ThemeKit.shared.windowThemePolicy = .themeAllWindows
        //ThemeKit.shared.windowThemePolicy = .themeSomeWindows(windowClasses: [MyCustomWindow.self])
        //ThemeKit.shared.windowThemePolicy = .doNotThemeSomeWindows(windowClasses: [NSPanel.self])
        //ThemeKit.shared.windowThemePolicy = .doNotThemeWindows
        
        // 2.2 User themes folder
        let workingDirectory = FileManager.default.currentDirectoryPath
        if workingDirectory != "/" {
            // probably launching from Xcode, point to project `Themes` folder so
            // users can easily test the live editing of `.theme` files
            let projectRootURL = URL(fileURLWithPath: workingDirectory, isDirectory: true).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Themes")
            ThemeKit.shared.userThemesFolderURL = projectRootURL
        }
        else {
            // otherwise, just point to the bundled Resources folder
            ThemeKit.shared.userThemesFolderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        }
        // let users know about our choosen user themes folder
        NSLog("ThemeKit.shared.userThemesFolderURL: %@", ThemeKit.shared.userThemesFolderURL!.path)
        
        // 2.3 You can define the default light and dark theme, used for `SystemTheme`
        //ThemeKit.lightTheme = ThemeKit.shared.theme(withIdentifier: PaperTheme.identifier)!
        //ThemeKit.darkTheme = ThemeKit.shared.theme(withIdentifier: "com.luckymarmot.ThemeKit.PurpleGreen")!
        
        // 2.4 Set default theme (default: macOS theme)
        ThemeKit.defaultTheme = ThemeKit.lightTheme
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Watch for theme changes and update Theme menu
        NotificationCenter.default.addObserver(self, selector: #selector(updateThemeMenu(_:)), name: .didChangeTheme, object: nil)
        
        // Build theme menu
        updateThemeMenu()
    }
    
    @objc private func updateThemeMenu(_ notification: Notification? = nil) {
        // Clean menu
        themeMenu.removeAllItems()
        
        // Add themes
        var counter = 1
        for theme in ThemeKit.shared.themes {
            let item = NSMenuItem(title: theme.shortDisplayName, action: #selector(switchTheme(_:)), keyEquivalent: String(counter))
            item.representedObject = theme
            item.state = (ThemeKit.shared.theme.identifier == theme.identifier) ? NSOnState : NSOffState
            themeMenu.addItem(item)
            counter += 1
        }
    }
    
    @IBAction func switchTheme(_ menuItem: NSMenuItem) {
        guard menuItem.representedObject != nil else { return }
        
        ThemeKit.shared.theme = menuItem.representedObject! as! Theme
        updateThemeMenu()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private var tabs: [NSWindowController] = []
    
    @IBAction func newWindowForTab(_ sender: Any?) {
        let storyBoard = NSStoryboard(name: "Main", bundle:nil)
        let windowController = storyBoard.instantiateController(withIdentifier: "WindowController") as! NSWindowController
        windowController.showWindow(self)
    }

}

