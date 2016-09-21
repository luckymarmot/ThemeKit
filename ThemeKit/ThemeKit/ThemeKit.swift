//
//  ThemeKit.swift
//  CoreColor
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import QuartzCore

/** 
 ThemeKit
 ========
 ThemeKit is a drop-in Swift 3 library that provides theming capabilities to
 both Swift and Objective-C Mac applications.

 Basic Usage
 -----------
 At its simpler usage, applications can be themed with a single line command:
 ```
 // Apply the dark theme
 ThemeKit.darkTheme.apply()

 // Apply the light theme
 ThemeKit.lightTheme.apply()
 
 // Apply the 'system' theme which dynamically changes to light or dark, 
 // respecting Preferences > General setting
 ThemeKit.systemTheme.apply()
 ```

 Window Theme Policy
 -------------------
 By default, all application windows will be themed, but this can be changed:

 ```
 // Theme all application windows (default)
 ThemeKit.shared.windowThemePolicy = .themeAllWindows
 
 // Only theme windows of the specified class names
 ThemeKit.shared.windowThemePolicy = .themeSomeWindows(windowClassNames: [MyWindow.className()])
 
 /// Do not theme any window
 ThemeKit.shared.windowThemePolicy = .doNotThemeWindows
 ```
 
 Note: despite of the configured policy, individual windows can be explictly themed
 with `aWindow.theme()` or `aWindow.themeIfCompliantWithWindowThemePolicy()`.
 
 Window theme policy must be configured on the `applicationWillFinishLaunching(_:)` method.
 
 Theme-Aware Assets
 ------------------
 Theme-aware colors and gradients dynamically change when the application theme 
 changes. For example, a `ThemeColor.brandColor` can be defined that resolves to
 blue for the light theme and to white for the dark theme.
 
 Please refer to `ThemeColor` and `ThemeGradient` for more information.
 
 User Themes
 -----------
 Besides the theme-aware theme assets (colors and gradients) that can be specified with the
 light and dark themes, custom themes can be made with simple text files.
 You can check the sample `Demo.theme` file on GitHub project page for an example.
 
 Just like other ThemeKit settings, user themes folder must be configured on 
 the `applicationWillFinishLaunching(_:)` method.
 
 ```
 // Configure ThemeKit to use `Application Support/{bundle_id}/Themes` folder
 ThemeKit.shared.userThemesFolderURL = ThemeKit.shared.applicationSupportUserThemesFolderURL
 ```
 
 Please refer to `UserTheme` for more information.
 
 Notifications
 -------------
 ThemeKit provides the following notifications:
 
 - `Notification.Name.willChangeTheme` is sent when current theme is about to change
 - `Notification.Name.didChangeTheme` is sent when current theme did change
 - `Notification.Name.didChangeSystemTheme` is sent when system theme did change (System Preference > General)
 */
@objc(TKThemeKit)
public class ThemeKit: NSObject {
    
    /// **ThemeKit** shared instance
    @objc(sharedInstance)
    public static let shared = ThemeKit()
    
    
    // MARK:- ThemeKit Configuration
    
    /// Window theme policies that define which windows should be automatically themed, if any.
    public enum WindowThemePolicy {
        /// Theme all application windows (default).
        case themeAllWindows
        /// Only theme windows of the specified class names.
        case themeSomeWindows(windowClassNames: [String])
        /// Do not theme any window.
        case doNotThemeWindows
    }
    
    /// Current window theme policy.
    public var windowThemePolicy: WindowThemePolicy = .themeAllWindows
    
    /// Location of user provided themes (.theme files).
    public var userThemesFolderURL: URL? {
        get {
            return _userThemesFolderURL
        }
        set(url) {
            _setUserThemesFolderURL(url!)
        }
    }
    
    
    // MARK:- Initialization & Cleanup
    
    open override class func initialize() {
        // Observe when application did finish launching
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSApplicationDidFinishLaunching, object: nil, queue: nil) { (Notification) in
            // Apply theme from User Defaults
            ThemeKit.shared.applyThemeFromUserDefaults()
            
            // Observe and theme new windows (before being displayed onscreen)
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowDidUpdate, object: nil, queue: nil) { (notification) in
                let window = notification.object as! NSWindow?
                window?.themeIfCompliantWithWindowThemePolicy()
            }
        }
    }
    
    private override init() {
        super.init()

        // Observe current theme on User Defaults
        NSUserDefaultsController.shared().addObserver(self, forKeyPath: _themeChangeKVOKeyPath, options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        
        // Observe current system theme (macOS Apple Interface Theme)
        NotificationCenter.default.addObserver(self, selector: #selector(systemThemeDidChange(_:)), name: .didChangeSystemTheme, object: nil)
    }
    
    deinit {
        NSUserDefaultsController.shared().removeObserver(self, forKeyPath: _themeChangeKVOKeyPath)
    }
    
    /// User Defaults Key
    static let UserDefaultsThemeKey = "ThemeKitTheme"
    
    
    // MARK:- Themes
    
    /// Current effective theme (read-only).
    /// This can return a different result than `theme`, as is current theme is
    /// set to `SystemTheme`, effective theme will be either `LightTheme` or `DarkTheme`.
    public var effectiveTheme: Theme {
        return _effectiveTheme ?? defaultTheme
    }
    private var _effectiveTheme: Theme?
    
    /// Currently applied/selected theme (stored on user preferences).
    public var theme: Theme {
        get {
            return _theme ?? defaultTheme
        }
        set(theme) {
            _theme = theme
            
            // Store identifier on user defaults
            UserDefaults.standard.set(theme.identifier, forKey: ThemeKit.UserDefaultsThemeKey)
            
            // Switch theme with animation
            _changeCurrentThemeWithAnimation()
        }
    }
    private var _theme: Theme?
    
    /// List of all available themes (includes user themes as well).
    public var themes: [Theme] {
        if _themes == nil {
            var available = [Theme]()
            
            // Builtin themes
            available.append(ThemeKit.lightTheme)
            available.append(ThemeKit.darkTheme)
            available.append(ThemeKit.systemTheme)
            
            // User provided themes
            for filename in userThemesFileNames {
                let themeFileURL = userThemesFolderURL?.appendingPathComponent(filename)
                if themeFileURL != nil {
                    available.append(UserTheme.init(themeFileURL!))
                }
            }
            
            _themes = available
        }
        return _themes!
    }
    private var _themes: [Theme]?
    
    /// Light theme.
    public static let lightTheme = LightTheme()
    
    /// Dark theme.
    public static let darkTheme = DarkTheme()
    
    /// System theme (resolves to LightTheme or Dark Theme; @see SystemTheme).
    public static let systemTheme = SystemTheme()
    
    /// Default theme to be used when none configured.
    public var defaultTheme: Theme {
        return ThemeKit.lightTheme
    }
    
    /// Get theme with specified identifier.
    public func theme(_ identifier: String?) -> Theme? {
        guard identifier != nil else {
            return nil
        }
        for theme in themes {
            if theme.identifier == identifier {
                return theme
            }
        }
        return nil
    }
    
    /// Apple Interface theme has changed.
    func systemThemeDidChange(_ notification: Notification) {
        _changeCurrentThemeWithAnimation()
    }
    
    
    // MARK:- Appearances
    
    /// Appearance in use for effective theme.
    public var effectiveThemeAppearance: NSAppearance {
        return effectiveTheme.isLightTheme ? lightAppearance : darkAppearance
    }
    
    /// Convenience method to get the light appearance.
    public var lightAppearance: NSAppearance {
        return NSAppearance.init(named: NSAppearanceNameVibrantLight)!
    }
    
    /// Convenience method to get the dark appearance.
    public var darkAppearance: NSAppearance {
        return NSAppearance.init(named: NSAppearanceNameVibrantDark)!
    }
    
    
    // MARK:- User Themes
    
    /// Convenience function to for "Application Support/{app_bundle_id}/Themes".
    public var applicationSupportUserThemesFolderURL: URL {
        let applicationSupportURLs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let thisAppSupportURL = URL.init(fileURLWithPath: applicationSupportURLs.first!).appendingPathComponent(Bundle.main.bundleIdentifier!)
        return thisAppSupportURL.appendingPathComponent("Themes")
    }
    
    /// List of user themes file names.
    public var userThemesFileNames: [String] {
        guard userThemesFolderURL != nil && FileManager.default.fileExists(atPath: (userThemesFolderURL?.path)!, isDirectory: nil) else {
            return []
        }
        let folderFiles = try! FileManager.default.contentsOfDirectory(atPath: (userThemesFolderURL?.path)!) as NSArray
        let themeFileNames = folderFiles.filtered(using: NSPredicate.init(format: "self ENDSWITH '.theme'", argumentArray: nil))
        return themeFileNames.map({ (fileName: Any) -> String in
            return fileName as! String
        })
    }
    
    private var _userThemesFolderURL: URL?
    private var _userThemesFolderQueue: DispatchQueue?
    private var _userThemesFolderSource: DispatchSourceFileSystemObject?
    
    /// Observe User Themes folder via CGD dispatch sources
    private func _setUserThemesFolderURL(_ url: URL) {
        if url != _userThemesFolderURL {
            // Clean up previous
            _userThemesFolderSource?.cancel()
            
            // Create folder if needed
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
            // Initialize file descriptor
            let fileDescriptor = open((url.path as NSString).fileSystemRepresentation, O_EVTONLY)
            guard fileDescriptor >= 0 else {
                return
            }
            _userThemesFolderURL = url
            
            // Initialize dispatch queue
            _userThemesFolderQueue = DispatchQueue(label: "com.luckymarmot.ThemeKit.UserThemesFolderQueue")
            
            // Watch file descriptor for writes
            _userThemesFolderSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: DispatchSource.FileSystemEvent.write)
            _userThemesFolderSource?.setEventHandler(handler: { 
                self._userThemesFolderChangedContent()
            })
            
            // Clean up when dispatch source is cancelled
            _userThemesFolderSource?.setCancelHandler {
                close(fileDescriptor)
            }
            
            // Start watching
            willChangeValue(forKey: #keyPath(themes))
            _themes = nil
            _userThemesFolderSource?.resume()
            didChangeValue(forKey: #keyPath(themes))
            
            // Re-apply current theme as current theme may be an user provided theme)
            applyThemeFromUserDefaults()
        }
    }
    
    /// Called when themes folder has file changes --> refresh modified user theme (if current).
    private func _userThemesFolderChangedContent() {
        willChangeValue(forKey: #keyPath(themes))
        _themes = nil
        
        if effectiveTheme is UserTheme {
            applyThemeFromUserDefaults()
        }
        
        didChangeValue(forKey: #keyPath(themes))
    }
    
    
    // MARK:- NSUserDefaultsController KVO
    
    private var _themeChangeKVOKeyPath: String = "values.\(ThemeKit.UserDefaultsThemeKey)"
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == _themeChangeKVOKeyPath else { return }
        
        // Theme selected on user defaults
        let userDefaultsThemeIdentifier = UserDefaults.standard.string(forKey: ThemeKit.UserDefaultsThemeKey)
        
        // Theme was changed on user defaults -> select
        if userDefaultsThemeIdentifier != theme.identifier {
            applyThemeFromUserDefaults()
        }
    }
    
    
    // MARK:- Theme Switching
    
    /// Apply theme stored on user defaults (or default one).
    public func applyThemeFromUserDefaults() {
        let userDefaultsTheme = theme(UserDefaults.standard.string(forKey: ThemeKit.UserDefaultsThemeKey))
        (userDefaultsTheme ?? defaultTheme).apply()
    }
    
    private func _changeCurrentTheme() {
        // Determine new theme
        let oldTheme: Theme = effectiveTheme
        var newTheme: Theme
        if theme.isAutoTheme {
            newTheme = theme.isDarkTheme ? ThemeKit.darkTheme : ThemeKit.lightTheme
        }
        else {
            newTheme = theme
        }
        
        // Apply & Propagate changes
        func applyAndPropagate(_ theme: Theme) {
            Thread.onMain {
                // Will change...
                self.willChangeValue(forKey: #keyPath(effectiveTheme))
                NotificationCenter.default.post(name: .willChangeTheme, object: self.effectiveTheme)
                
                // ...change...
                self._effectiveTheme = theme
                
                // ...did change!
                NotificationCenter.default.post(name: .didChangeTheme, object: self.effectiveTheme)
                self.didChangeValue(forKey: #keyPath(effectiveTheme))
                
                // Theme all windows compliant to current `windowThemePolicy`
                NSWindow.themeAllWindows()
            }
        }
        
        // If we are switching light-to-light or dark-to-dark themes, macOS won't
        // refresh appearance on controls => need to 'tilt' appearance to force refresh!
        if oldTheme.isLightTheme == newTheme.isLightTheme {
            // Switch to "inverted" theme (light -> dark, dark -> light)
            applyAndPropagate(oldTheme.isLightTheme ? ThemeKit.darkTheme : ThemeKit.lightTheme)
        }
        
        // Switch to new theme
        applyAndPropagate(newTheme)
    }
    
    private var _currentTransitionWindows: Set<NSWindow> = Set()
    
    private func _changeCurrentThemeWithAnimation() {
        Thread.onMain {
            // Find windows to animate
            let windows = NSWindow.windowsCompliantWithWindowThemePolicy()
            guard windows.count > 0 else {
                // Change theme without animation
                self._changeCurrentTheme()
                return
            }
            
            // Create transition windows off-screen
            var transitionWindows = [Int : NSWindow]()
            for window in windows {
                let windowNumber = window.windowNumber
                /* Make sure the window has a number, and that it's not one of our
                 * existing transition windows */
                if windowNumber > 0 && !self._currentTransitionWindows.contains(window) {
                    let transitionWindow = window.makeScreenshotWindow()
                    transitionWindows[windowNumber] = transitionWindow
                    self._currentTransitionWindows.insert(transitionWindow)
                }
            }
            
            // Show (if we have at least one window to animate)
            if transitionWindows.count > 0 {
                // Show them all (hidden)
                for (windowNumber, transitionWindow) in transitionWindows {
                    transitionWindow.alphaValue = 0.0
                    let parentWindow = NSApp.window(withWindowNumber: windowNumber)
                    parentWindow?.addChildWindow(transitionWindow, ordered: .above)
                }
                
                // Setup animation
                NSAnimationContext.beginGrouping()
                let ctx = NSAnimationContext.current()
                ctx.duration = 0.3
                ctx.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                ctx.completionHandler = {() -> Void in
                    for transitionWindow in transitionWindows.values {
                        transitionWindow.orderOut(self)
                        self._currentTransitionWindows.remove(transitionWindow)
                    }
                }

                // Show them all and fade out
                for transitionWindow in transitionWindows.values {
                    transitionWindow.alphaValue = 1.0
                    transitionWindow.animator().alphaValue = 0.0
                }
                NSAnimationContext.endGrouping()

            }

            // Change theme
            self._changeCurrentTheme()
        }
    }
    
}

