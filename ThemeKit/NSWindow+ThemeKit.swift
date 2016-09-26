//
//  NSWindow+ThemeKit.swift
//  CoreColor
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

public extension NSWindow {
    
    // MARK:- Public
    
    /// Theme all windows compliant to ThemeKit.windowThemePolicy (and if needed).
    public static func themeAllWindows() {
        for window in windowsCompliantWithWindowThemePolicy() {
            window.theme()
        }
    }
    
    /// Theme window if needed.
    public func theme() {
        // Change window tab bar appearance
        themeTabBar()
        
        // Change window appearance
        themeWindow()
    }
    
    /// Theme window if compliant to ThemeKit.windowThemePolicy (and if needed).
    public func themeIfCompliantWithWindowThemePolicy() {
        if isCompliantWithWindowThemePolicy() {
            theme()
        }
    }
    
    
    // MARK:- Private
    // MARK:- Window theme policy compliance
    
    /// Check if window is compliant with ThemeKit.windowThemePolicy.
    internal func isCompliantWithWindowThemePolicy() -> Bool {
        switch ThemeKit.shared.windowThemePolicy {
            
        case .themeAllWindows:
            return true
            
        case .themeSomeWindows(let windowClassNames):
            for windowClassName in (windowClassNames as [String]) {
                if self.className == windowClassName {
                    return true
                }
            }
            return false
            
        case .doNotThemeWindows:
            return false
        }
    }
    
    /// List of all existing windows compliant to ThemeKit.windowThemePolicy.
    internal static func windowsCompliantWithWindowThemePolicy() -> [NSWindow] {
        var windows = [NSWindow]()
        
        switch ThemeKit.shared.windowThemePolicy {
            
        case .themeAllWindows:
            windows = NSApplication.shared().windows
            
        case .themeSomeWindows(let windowClassNames):
            let windowsMatchingClasses = NSApplication.shared().windows.filter({ (window) -> Bool in
                for windowClassName in (windowClassNames as [String]) {
                    if window.className == windowClassName {
                        return true
                    }
                }
                return false
            })
            windows.append(contentsOf: windowsMatchingClasses)
            
        case .doNotThemeWindows:
            break
        }
        
        return windows
    }
    
    
    // MARK:- Window screenshots
    
    /// Take window screenshot.
    internal func takeScreenshot() -> NSImage {
        let cgImage = CGWindowListCreateImage(CGRect.null, .optionIncludingWindow, CGWindowID(windowNumber), .boundsIgnoreFraming)
        let image = NSImage(cgImage: cgImage!, size: frame.size)
        image.cacheMode = NSImageCacheMode.never
        image.size = frame.size
        return image
    }
    
    /// Create a window with a screenshot of current window.
    internal func makeScreenshotWindow() -> NSWindow {
        // Take window screenshot
        let screenshot = takeScreenshot()
        
        // Create "image-window"
        let window = NSWindow(contentRect: frame, styleMask: NSWindowStyleMask.borderless, backing: NSBackingStoreType.buffered, defer: true)
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = NSWindowCollectionBehavior.stationary
        window.titlebarAppearsTransparent = true
        
        // Add image view
        let imageView = NSImageView(frame: NSMakeRect(0, 0, screenshot.size.width, screenshot.size.height))
        imageView.image = screenshot
        window.contentView?.addSubview(imageView)
        
        return window
    }
    
    
    // MARK:- Tab bar view
    
    /// Returns the tab bar view.
    private var tabBar: NSView? {
        // If we found before, return it
        if windowTabBar != nil {
            return windowTabBar
        }
        
        var tabBar: NSView?
        
        // Search on titlebar accessory views if supported (will fail if tab bar is hidden)
        let themeFrame = self.contentView?.superview
        if (themeFrame?.responds(to: #selector(getter: titlebarAccessoryViewControllers)))! {
            for controller: NSTitlebarAccessoryViewController in self.titlebarAccessoryViewControllers {
                let possibleTabBar = controller.view.deepSubview(withClassName: "NSTabBar")
                if possibleTabBar != nil {
                    tabBar = possibleTabBar
                    break
                }
            }
        }
        
        // Search down the title bar view
        if tabBar == nil {
            let titlebarContainerView = themeFrame?.deepSubview(withClassName: "NSTitlebarContainerView")
            let titlebarView = titlebarContainerView?.deepSubview(withClassName: "NSTitlebarView")
            tabBar = titlebarView?.deepSubview(withClassName: "NSTabBar")
        }
        
        // Remember it
        if tabBar != nil {
            windowTabBar = tabBar
        }
        
        return tabBar
    }
    
    /// Holds a reference to tabbar as associated object
    private var windowTabBar: NSView? {
        get {
            return objc_getAssociatedObject(self, &tabbarAssociationKey) as? NSView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tabbarAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Check if tab bar is visbile.
    private var isTabBarVisible: Bool {
        return tabBar?.superview != nil;
    }
    
    /// Update window appearance (if needed).
    private func themeWindow() {
        if appearance != ThemeKit.shared.effectiveThemeAppearance {
            // Change window appearance
            appearance = ThemeKit.shared.effectiveThemeAppearance
            
            // Invalidate shadow as sometimes it is incorrecty drawn or missing
            invalidateShadow()
            
            // Trick to force update of all CALayers in deep & private views
            titlebarAppearsTransparent = !titlebarAppearsTransparent
            DispatchQueue.main.async {
                self.titlebarAppearsTransparent = !self.titlebarAppearsTransparent
            }
        }
    }
    
    /// Update tab bar appearance (if needed).
    private func themeTabBar() {
        if isTabBarVisible {
            let _tabBar = tabBar
            if _tabBar?.appearance != ThemeKit.shared.effectiveThemeAppearance {
                _tabBar?.appearance = ThemeKit.shared.effectiveThemeAppearance
                for tabBarSubview: NSView in (tabBar?.subviews)! {
                    tabBarSubview.needsDisplay = true
                }
            }
        }
    }
    
    
    // MARK:- Title bar view
    
    /// Returns the title bar view.
    private var titlebarView: NSView? {
        let themeFrame = self.contentView?.superview
        let titlebarContainerView = themeFrame?.deepSubview(withClassName: "NSTitlebarContainerView")
        return titlebarContainerView?.deepSubview(withClassName: "NSTitlebarView")
    }
}

private var tabbarAssociationKey: UInt8 = 0
