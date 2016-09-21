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
        // Setup window theme policy
        //ThemeKit.shared.windowThemePolicy = .themeAllWindows
        //ThemeKit.shared.windowThemePolicy = .themeSomeWindows(windowClassNames: [MyWindow.className()])
        //ThemeKit.shared.windowThemePolicy = .doNotThemeWindows
        
        // User themes folder
        let workingDirectory = FileManager.default.currentDirectoryPath
        let projectRootURL = URL(fileURLWithPath: workingDirectory, isDirectory: true).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        ThemeKit.shared.userThemesFolderURL = projectRootURL
        //ThemeKit.darkTheme.apply()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
}

