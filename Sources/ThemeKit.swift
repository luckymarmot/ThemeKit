//
//  ThemeKit.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import QuartzCore

/**
 Use `ThemeKit` shared instance to perform app-wide theming related operations, 
 such as:
 
 - Get information about current theme/appearance
 - Change current `theme` (can also be changed from `NSUserDefaults`)
 - List available themes
 - Define `ThemeKit` behaviour 
 
 */
@objc(TKThemeKit)
public class ThemeKit: NSObject {
    
    /// ThemeKit shared instance.
    @objc(sharedInstance)
    public static let shared = ThemeKit()
    
    // MARK: -
    // MARK: Initialization & Cleanup
    
    open override class func initialize() {
        // Observe when application did finish launching
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSApplicationDidFinishLaunching, object: nil, queue: nil) { (Notification) in
            // Apply theme from User Defaults
            ThemeKit.shared.applyUserDefaultsTheme()
            
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
    
    
    // MARK: -
    // MARK: Themes

    /// Returns the current theme.
    ///
    /// This property is KVO compliant. Value is stored on user defaults under key
    /// `userDefaultsThemeKey`.
    public var theme: Theme {
        get {
            return _theme ?? ThemeKit.defaultTheme
        }
        set(newTheme) {
            // Store identifier on user defaults
            if newTheme.identifier != UserDefaults.standard.string(forKey: ThemeKit.userDefaultsThemeKey) {
                UserDefaults.standard.set(newTheme.identifier, forKey: ThemeKit.userDefaultsThemeKey)
            }
            
            // Apply theme
            if _theme == nil || newTheme != _theme! || newTheme is UserTheme {
                applyTheme(newTheme)
            }
        }
    }
    /// Internal storage for `theme` property. Doesn't trigger an `applyTheme()` call.
    private var _theme: Theme?
    
    /// Returns the current effective theme (read-only).
    ///
    /// This property is KVO compliant. This can return a different result than
    /// `theme`, as if current theme is set to `SystemTheme`, effective theme
    /// will be either `lightTheme` or `darkTheme`, respecting user preference at
    /// **System Preferences > General > Appearance**.
    public var effectiveTheme: Theme {
        return theme.effectiveTheme
    }
    
    /// List all available themes:
    ///
    /// - `lightTheme`
    /// - `darkTheme`
    /// - `systemTheme`
    /// - All user themes (loaded from `.theme` files)
    ///
    /// This property is KVO compliant and will change when changes occur on user
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
                if let themeFileURL = userThemesFolderURL?.appendingPathComponent(filename) {
                    available.append(UserTheme.init(themeFileURL))
                }
            }
            
            cachedThemes = available
        }
        return cachedThemes!
    }
    
    /// Cached themes list (private use).
    private var cachedThemes: [Theme]?
    
    /// Convenience method for accessing the light theme.
    public static let lightTheme = LightTheme()
    
    /// Convenience method for accessing the dark theme.
    public static let darkTheme = DarkTheme()
    
    /// Convenience method for accessing the theme that dynamically changes to
    /// `lightTheme` or `darkTheme`, respecting user preference at
    /// **System Preferences > General > Appearance**.
    public static let systemTheme = SystemTheme()
    
    /// Returns default theme to be used for the first time (`systemTheme`).
    public static var defaultTheme: Theme {
        return ThemeKit.systemTheme
    }
    
    /// Get the theme with specified identifier.
    ///
    /// - parameter identifier: The unique `Theme.identifier` string.
    ///
    /// - returns: The `Theme` instance with the given identifier.
    public func theme(withIdentifier identifier: String?) -> Theme? {
        if let themeIdentifier: String = identifier {
            for theme in themes {
                if theme.identifier == themeIdentifier {
                    return theme
                }
            }
        }
        return nil
    }
    
    /// User defaults key for current `theme`.
    ///
    /// Current `theme.identifier` will be stored under the `"ThemeKitTheme"` `NSUserDefaults` key.
    static public let userDefaultsThemeKey = "ThemeKitTheme"
    
    /// Apply theme stored on user defaults (or default `ThemeKit.defaultTheme`).
    private func applyUserDefaultsTheme() {
        let userDefaultsTheme = theme(withIdentifier: UserDefaults.standard.string(forKey: ThemeKit.userDefaultsThemeKey))
        (userDefaultsTheme ?? ThemeKit.defaultTheme).apply()
    }
    
    /// Apple Interface theme has changed.
    ///
    /// - parameter notification: A `.didChangeSystemTheme` notification.
    @objc private func systemThemeDidChange(_ notification: Notification) {
        if theme.isAutoTheme {
            applyTheme(theme)
        }
    }
    
    
    // MARK: -
    // MARK: User Themes (`.theme` files)
    
    /// Location of user provided themes (.theme files).
    ///
    /// Ideally, this should be on a shared location, like `Application Support/{app_bundle_id}/Themes`
    /// for example. Here's an example of how to get this folder:
    ///
    /// ```swift
    /// public var applicationSupportUserThemesFolderURL: URL {
    ///   let applicationSupportURLs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    ///   let thisAppSupportURL = URL.init(fileURLWithPath: applicationSupportURLs.first!).appendingPathComponent(Bundle.main.bundleIdentifier!)
    ///   return thisAppSupportURL.appendingPathComponent("Themes")
    /// }
    /// ```
    ///
    /// You can also bundle these files with your application bundle, if you 
    /// don't want them to be changed.
    public var userThemesFolderURL: URL? {
        didSet {
            // Clean up previous
            _userThemesFolderSource?.cancel()
            
            // Observe User Themes folder via CGD dispatch sources
            if userThemesFolderURL != nil && userThemesFolderURL! != oldValue {
                // Create folder if needed
                try! FileManager.default.createDirectory(at: userThemesFolderURL!, withIntermediateDirectories: true, attributes: nil)
                
                // Initialize file descriptor
                let fileDescriptor = open((userThemesFolderURL!.path as NSString).fileSystemRepresentation, O_EVTONLY)
                guard fileDescriptor >= 0 else { return }
                
                // Initialize dispatch queue
                _userThemesFolderQueue = DispatchQueue(label: "com.luckymarmot.ThemeKit.UserThemesFolderQueue")
                
                // Watch file descriptor for writes
                _userThemesFolderSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: DispatchSource.FileSystemEvent.write)
                _userThemesFolderSource?.setEventHandler(handler: {
                    self.userThemesFolderChangedContent()
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
                
                // Re-apply current theme if user theme
                if theme is UserTheme {
                    applyUserDefaultsTheme()
                }
            }
        }
    }
    
    /// List of user themes file names.
    private var userThemesFileNames: [String] {
        guard userThemesFolderURL != nil && FileManager.default.fileExists(atPath: userThemesFolderURL!.path, isDirectory: nil) else {
            return []
        }
        let folderFiles = try! FileManager.default.contentsOfDirectory(atPath: userThemesFolderURL!.path) as NSArray
        let themeFileNames = folderFiles.filtered(using: NSPredicate.init(format: "self ENDSWITH '.theme'", argumentArray: nil))
        return themeFileNames.map({ (fileName: Any) -> String in
            return fileName as! String
        })
    }
    
    /// Dispatch queue for monitoring the user themes folder.
    private var _userThemesFolderQueue: DispatchQueue?
    
    /// Filesustem dispatch source for monitoring the user themes folder.
    private var _userThemesFolderSource: DispatchSourceFileSystemObject?
    
    /// Called when themes folder has file changes --> refresh modified user theme (if current).
    private func userThemesFolderChangedContent() {
        willChangeValue(forKey: #keyPath(themes))
        cachedThemes = nil
        
        if effectiveTheme is UserTheme {
            applyUserDefaultsTheme()
        }
    
        didChangeValue(forKey: #keyPath(themes))
    }
    
    
    // MARK: -
    // MARK: Appearances
    
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
    
    // MARK: -
    // MARK: Window Theming Policy
    
    /// Window theme policies that define which windows should be automatically themed, if any.
    ///
    /// Swift
    /// -----
    /// By default, all application windows will be themed (`.themeAllWindows`).
    ///
    /// - themeAllWindows:   Theme all application windows (default).
    /// - themeSomeWindows:  Only theme windows of the specified classes.
    /// - doNotThemeWindows: Do not theme any window.E.g.:
    ///
    /// E.g.:
    ///
    /// ```
    /// ThemeKit.shared.windowThemePolicy = .themeSomeWindows(windowClasses: [CustomWindow.self])
    /// ```
    ///
    /// Objective-C
    /// -----------
    /// By default, all application windows will be themed (`.TKThemeKitWindowThemePolicyThemeAllWindows`).
    ///
    /// - TKThemeKitWindowThemePolicyThemeAllWindows:   Theme all application windows (default).
    /// - TKThemeKitWindowThemePolicyThemeSomeWindowClasses:  Only theme windows of the specified classes.
    /// - TKThemeKitWindowThemePolicyDoNotThemeWindows: Do not theme any window.
    ///
    /// If `.windowThemePolicy = TKThemeKitWindowThemePolicyThemeSomeWindowClasses`
    /// is set, themable window class names can then be defined using
    /// `NSArray<NSString*>* themableWindowClassNames` property. E.g.:
    ///
    /// ```
    /// [TKThemeKit sharedInstance].windowThemePolicy = TKThemeKitWindowThemePolicyThemeSomeWindowClasses;
    /// [TKThemeKit sharedInstance].themableWindowClassNames = @[[CustomWindow class]];
    /// ```
    ///
    /// NSWindow Extension
    /// ------------------
    ///
    /// - `NSWindow.theme()`
    ///
    ///     Theme window if appearance needs update. Doesn't check for policy compliance.
    /// - `NSWindow.isCompliantWithWindowThemePolicy()`
    ///
    ///     Check if window complies to current policy.
    /// - `NSWindow.themeIfCompliantWithWindowThemePolicy()`
    ///
    ///     Theme window if compliant to `windowThemePolicy` (and if appearance needs update).
    /// - `NSWindow.themeAllWindows()`
    ///
    ///     Theme all windows compliant to ThemeKit.windowThemePolicy (and if appearance needs update).
    public enum WindowThemePolicy {
        /// Theme all application windows (default).
        case themeAllWindows
        /// Only theme windows of the specified classes.
        case themeSomeWindows(windowClasses: [AnyClass])
        /// Do not theme any window.
        case doNotThemeWindows
    }
    
    /// Current window theme policy.
    public var windowThemePolicy: WindowThemePolicy = .themeAllWindows
    
    
    // MARK: -
    // MARK: Theme Switching
    
    /// Keypath for string `values.ThemeKitTheme`.
    private var themeChangeKVOKeyPath: String = "values.\(ThemeKit.userDefaultsThemeKey)"
    
    // Called when theme is changed on `NSUserDefaults`.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == themeChangeKVOKeyPath else { return }
        
        // Theme selected on user defaults
        let userDefaultsThemeIdentifier = UserDefaults.standard.string(forKey: ThemeKit.userDefaultsThemeKey)
        
        // Theme was changed on user defaults -> apply
        if userDefaultsThemeIdentifier != theme.identifier {
            applyUserDefaultsTheme()
        }
    }
    
    /// Screenshot-windows used during theme animated transition.
    private var themeTransitionWindows: Set<NSWindow> = Set()
    
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
                if windowNumber > 0 && !self.themeTransitionWindows.contains(window) {
                    let transitionWindow = window.makeScreenshotWindow()
                    transitionWindows[windowNumber] = transitionWindow
                    self.themeTransitionWindows.insert(transitionWindow)
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
                        self.themeTransitionWindows.remove(transitionWindow)
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

