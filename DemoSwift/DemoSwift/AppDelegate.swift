//
//  AppDelegate.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 07/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    open override class func initialize() {
        ValueTransformer.setValueTransformer(DefaultThemeValueTransformer(), forName: NSValueTransformerName(rawValue: "DefaultThemeValueTransformer"))
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        /* 1. Simpler usage: switch between light and dark theme */
        
        //ThemeKit.lightTheme.apply()
        //ThemeKit.darkTheme.apply()
        //ThemeKit.systemTheme.apply()
        
        
        /* 2. Advacned usage: define window theme policy & enable user themes.
         * Themes will be selected using popup bound to user defaults. */
        
        // 2.1 Setup window theme policy
        ThemeKit.shared.windowThemePolicy = .themeAllWindows
        //ThemeKit.shared.windowThemePolicy = .themeSomeWindows(windowClassNames: [MyWindow.className()])
        //ThemeKit.shared.windowThemePolicy = .doNotThemeWindows
        
        // 2.2 User themes folder
        let workingDirectory = FileManager.default.currentDirectoryPath
        let projectRootURL = URL(fileURLWithPath: workingDirectory, isDirectory: true).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        print("projectRootURL: \(projectRootURL)")
        ThemeKit.shared.userThemesFolderURL = projectRootURL
        // Alternatively, could use "Application Support/{app_bundle_id}/Themes"
        // ThemeKit.shared.userThemesFolderURL = ThemeKit.shared.applicationSupportUserThemesFolderURL
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func newWindowForTab(_ sender: Any?) {
        
    }
    
}

