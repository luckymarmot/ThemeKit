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
        //ThemeKit.shared.windowThemePolicy = .doNotThemeWindows
        
        // 2.2 User themes folder
        let workingDirectory = FileManager.default.currentDirectoryPath
        let projectRootURL = URL(fileURLWithPath: workingDirectory, isDirectory: true).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Themes")
        ThemeKit.shared.userThemesFolderURL = projectRootURL
        
        // 2.3 Set default theme (default: macOS theme)
        ThemeKit.defaultTheme = ThemeKit.lightTheme
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

