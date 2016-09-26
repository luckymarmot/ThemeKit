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
            ThemeKit.shared.applyStoredTheme()
            
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
        NSUserDefaultsController.shared().addObserver(self, forKeyPath: themeChangeKVOKeyPath, options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        
        // Observe current system theme (macOS Apple Interface Theme)
        NotificationCenter.default.addObserver(self, selector: #selector(systemThemeDidChange(_:)), name: .didChangeSystemTheme, object: nil)
    }
    
    deinit {
        NSUserDefaultsController.shared().removeObserver(self, forKeyPath: themeChangeKVOKeyPath)
    }
    
    /// User Defaults Key
    static let UserDefaultsThemeKey = "ThemeKitTheme"
    
    
    // MARK:- Themes
    
    /// Returns the current effective theme (read-only).
    /// Property is KVO compliant. This can return a different result than 
    /// `theme`, as if current theme is set to `SystemTheme`, effective theme 
    /// will be either `LightTheme` or `DarkTheme`.
    public var effectiveTheme: Theme {
        return theme.effectiveTheme
    }

    /// Returns the current theme.
    /// Property is KVO compliant. Value is stored on user defaults under key
    /// `ThemeKit.UserDefaultsThemeKey` (= "ThemeKitTheme").
    public var theme: Theme {
        get {
            return _theme ?? ThemeKit.defaultTheme
        }
        set(newTheme) {
            // Store identifier on user defaults
            if newTheme.identifier != UserDefaults.standard.string(forKey: ThemeKit.UserDefaultsThemeKey) {
                UserDefaults.standard.set(newTheme.identifier, forKey: ThemeKit.UserDefaultsThemeKey)
            }
            
            // Apply theme
            if _theme == nil || newTheme != _theme! {
                applyTheme(newTheme)
            }
        }
    }
    private var _theme: Theme?
    
    /// List of all available themes:
    /// - Light Theme
    /// - Dark Theme
    /// - All user themes (`.theme` files)
    ///
    /// Property is KVO compliant and will change when changes occur on user 
    /// themes folder.
    public var themes: [Theme] {
        if cachedThemes == nil {
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
            
            cachedThemes = available
        }
        return cachedThemes!
    }
    
    /// Cached themes list (private use).
    private var cachedThemes: [Theme]?
    
    /// Light theme.
    public static let lightTheme = LightTheme()
    
    /// Dark theme.
    public static let darkTheme = DarkTheme()
    
    /// Returns `lightTheme` or `darkTheme`, respecting user preference at
    /// *System Preferences > General > Appearance*.
    public static let systemTheme = SystemTheme()
    
    /// Returns default theme to be used for the first time (`systemTheme`).
    public static var defaultTheme: Theme {
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
        if theme.isAutoTheme {
            applyTheme(theme)
        }
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
            cachedThemes = nil
            _userThemesFolderSource?.resume()
            didChangeValue(forKey: #keyPath(themes))
            
            // Re-apply current theme as current theme may be an user provided theme)
            applyStoredTheme()
        }
    }
    
    /// Called when themes folder has file changes --> refresh modified user theme (if current).
    private func _userThemesFolderChangedContent() {
        willChangeValue(forKey: #keyPath(themes))
        cachedThemes = nil
        
        if effectiveTheme is UserTheme {
            applyStoredTheme()
        }
        
        didChangeValue(forKey: #keyPath(themes))
    }
    
    
    // MARK:- NSUserDefaultsController KVO
    
    private var themeChangeKVOKeyPath: String = "values.\(ThemeKit.UserDefaultsThemeKey)"
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == themeChangeKVOKeyPath else { return }
        
        // Theme selected on user defaults
        let userDefaultsThemeIdentifier = UserDefaults.standard.string(forKey: ThemeKit.UserDefaultsThemeKey)
        
        // Theme was changed on user defaults -> apply
        if userDefaultsThemeIdentifier != theme.identifier {
            applyStoredTheme()
        }
    }
    
    
    // MARK:- Theme Switching
    
    /// Apply theme stored on user defaults (or default one).
    public func applyStoredTheme() {
        let userDefaultsTheme = theme(UserDefaults.standard.string(forKey: ThemeKit.UserDefaultsThemeKey))
        (userDefaultsTheme ?? ThemeKit.defaultTheme).apply()
    }
    
    private var _currentTransitionWindows: Set<NSWindow> = Set()
    
    /// Apply a new `theme`
    private func applyTheme(_ newTheme: Theme) {
        
        // Make theme effective
        func makeThemeEffective(_ newTheme: Theme) {
            // Determine new theme
            let oldEffectiveTheme: Theme = effectiveTheme
            let newEffectiveTheme: Theme = newTheme.effectiveTheme
            
            // Apply & Propagate changes
            func applyAndPropagate(_ newTheme: Theme) {
                Thread.onMain {
                    // Will change...
                    self.willChangeValue(forKey: #keyPath(theme))
                    let changingEffectiveAppearance = self._theme == nil || self.effectiveTheme != newTheme.effectiveTheme
                    if changingEffectiveAppearance {
                        self.willChangeValue(forKey: #keyPath(effectiveTheme))
                    }
                    NotificationCenter.default.post(name: .willChangeTheme, object: newTheme)
                    
                    // Change effective theme
                    self._theme = newTheme
                    
                    // Did change!
                    self.didChangeValue(forKey: #keyPath(theme))
                    if changingEffectiveAppearance {
                        self.didChangeValue(forKey: #keyPath(effectiveTheme))
                    }
                    NotificationCenter.default.post(name: .didChangeTheme, object: newTheme)
                    
                    // Theme all windows compliant to current `windowThemePolicy`
                    NSWindow.themeAllWindows()
                }
            }
            
            // If we are switching light-to-light or dark-to-dark themes, macOS won't
            // refresh appearance on controls => need to 'tilt' appearance to force refresh!
            if oldEffectiveTheme.isLightTheme == newEffectiveTheme.isLightTheme && _theme != nil {
                // Switch to "inverted" theme (light -> dark, dark -> light)
                applyAndPropagate(oldEffectiveTheme.isLightTheme ? ThemeKit.darkTheme : ThemeKit.lightTheme)
            }
            
            // Switch to new theme
            applyAndPropagate(newTheme)
        }
        
        // Animate theme transition
        Thread.onMain {
            // Find windows to animate
            let windows = NSWindow.windowsCompliantWithWindowThemePolicy()
            guard windows.count > 0 else {
                // Change theme without animation
                makeThemeEffective(newTheme)
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

            // Actually change theme
            makeThemeEffective(newTheme)
        }
    }
    
}

