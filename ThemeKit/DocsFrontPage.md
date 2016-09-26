ThemeKit
========
ThemeKit is a drop-in Swift 3 library that provides theming capabilities to both Swift and Objective-C Mac applications.

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

Note: despite of the configured policy, individual windows can be explictly themed with `aWindow.theme()` or `aWindow.themeIfCompliantWithWindowThemePolicy()`.

Window theme policy must be configured on the `applicationWillFinishLaunching(_:)` method.

Theme-Aware Assets
------------------
Theme-aware colors and gradients dynamically change when the application theme  changes. For example, a `ThemeColor.brandColor` can be defined that resolves to blue for the light theme and to white for the dark theme.

Please refer to `ThemeColor` and `ThemeGradient` for more information.

User Themes
-----------
Besides the theme-aware theme assets (colors and gradients) that can be specified with the light and dark themes, custom themes can be made with simple text files.

Check this sample [`Demo.theme`](https://github.com/luckymarmot/ThemeKit/Demo.theme) file on GitHub project page for an example.

As recommended for other `ThemeKit` settings, user themes folder must be configured on 
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