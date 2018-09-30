//
//  AppDelegate.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa
import ThemeKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: -
    // MARK: App Launch

    func applicationWillFinishLaunching(_ notification: Notification) {

        /* 0. Enable/disable theming capabilities. */
        //ThemeManager.shared.isEnabled = false

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
        if let bundleResourcePath = Bundle.main.resourcePath {
            ThemeManager.shared.userThemesFolderURL = URL(fileURLWithPath: bundleResourcePath)
            NSLog("ThemeManager.shared.userThemesFolderURL: %@", ThemeManager.shared.userThemesFolderURL?.path ?? "-")
        }

        // 2.3 You can define the default light and dark theme, used for `ThemeManager.systemTheme`
        //if let paperTheme = ThemeManager.shared.theme(withIdentifier: PaperTheme.identifier) {
        //    ThemeManager.lightTheme = paperTheme
        //}
        //if let purpleGreenTheme = ThemeManager.shared.theme(withIdentifier: "com.luckymarmot.ThemeKit.PurpleGreen") {
        //    ThemeManager.darkTheme = purpleGreenTheme
        //}

        // 2.4 Set default theme (default: macOS theme `ThemeManager.systemTheme`)
        ThemeManager.defaultTheme = ThemeManager.lightTheme

        // 2.5 Animate theme transitions? (default = true)
        //ThemeManager.shared.animateThemeTransitions = false

        // 2.6 Apply last applied theme, or the default one
        ThemeManager.shared.applyLastOrDefaultTheme()

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Watch for theme changes and update Theme menu
        NotificationCenter.default.addObserver(self, selector: #selector(updateThemeMenu(_:)), name: .didChangeTheme, object: nil)

        // Build theme menu
        updateThemeMenu()
    }

    // MARK: -
    // MARK: Theme related

    @objc private func updateThemeMenu(_ notification: Notification? = nil) {
        // Clean menu
        themeMenu.removeAllItems()

        // Add themes
        var counter = 1
        for theme in ThemeManager.shared.themes {
            let item = NSMenuItem(title: theme.shortDisplayName, action: #selector(switchTheme(_:)), keyEquivalent: String(counter))
            item.representedObject = theme
            item.state = (ThemeManager.shared.theme.identifier == theme.identifier) ? .on : .off
            themeMenu.addItem(item)
            counter += 1
        }

        // Add separator
        themeMenu.addItem(NSMenuItem.separator())

        // Add slideshow
        let slideshowItem = NSMenuItem(title: "Slideshow", action: #selector(startStopThemeSlideshow), keyEquivalent: "0")
        slideshowItem.state = slideshowTimerOn ? .on : .off
        themeMenu.addItem(slideshowItem)
    }

    @IBAction func switchTheme(_ menuItem: NSMenuItem) {
        guard menuItem.representedObject != nil else { return }

        if let theme = menuItem.representedObject as? Theme {
            ThemeManager.shared.theme = theme
            updateThemeMenu()
        }
    }

    // MARK: -
    // MARK: Theme Slideshow

    /// Slideshow timer.
    private var slideshowTimer: Timer?

    /// Slideshow state.
    private var slideshowTimerOn: Bool {
        return (slideshowTimer?.isValid ?? false)
    }

    /// Themes used on slideshow. Indices from `ThemeManager.shared.themes`.
    private static let slideshowAllThemeIndices = [0, 1, 3, 4, 5, 6]
    private static let slideshowAnimatedGIFThemeIndices = [0, 1, 3, 5]
    private static let slideshowThemeIndices = AppDelegate.slideshowAllThemeIndices

    /// Start/stop theme slideshow.
    @objc func startStopThemeSlideshow() {
        if slideshowTimerOn {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        } else {
            slideshowTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(nextSlideshowTheme), userInfo: nil, repeats: true)
        }
    }

    /// Apply next slideshow theme.
    @objc func nextSlideshowTheme() {
        let themes = ThemeManager.shared.themes
        guard themes.count > 0 else {
            startStopThemeSlideshow()
            return
        }

        // Determine next theme
        var nextIndex = AppDelegate.slideshowThemeIndices[0]
        if let currentThemeIndex = themes.index(where: { $0 === ThemeManager.shared.theme }),
            let currentSlideshowIndex = AppDelegate.slideshowThemeIndices.index(of: currentThemeIndex),
            currentSlideshowIndex + 1 < AppDelegate.slideshowThemeIndices.count {
            nextIndex = AppDelegate.slideshowThemeIndices[currentSlideshowIndex + 1]
        }

        // Apply theme
        if nextIndex >= themes.count {
            nextIndex = 0
        }
        ThemeManager.shared.theme = themes[nextIndex]
        updateThemeMenu()
    }

    // As a bonus, a way of theming window titlebar is shown on
    // `WindowController` for illustrative purposes.

    // MARK: -
    // MARK: App Termination

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: -
    // MARK: Tabs

    private var tabs: [NSWindowController] = []

    @IBAction func newWindowForTab(_ sender: Any?) {
        let storyBoard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WindowController")) as? NSWindowController {
            windowController.showWindow(self)
        }
    }

    // MARK: -
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

    // MARK: -
    // MARK: Others

    // Weak control references
    @IBOutlet weak var themeMenu: NSMenu!

    // Strong controllers references
    @objc weak var sidebarViewController: SidebarViewController?

}

extension NSApplication {

    @objc static var sidebarViewController: SidebarViewController? {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            return appDelegate.sidebarViewController
        }
        return nil
    }

}
