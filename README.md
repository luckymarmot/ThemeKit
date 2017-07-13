<p align="left" style="margin-top: 20px;">
  <img src="https://github.com/luckymarmot/ThemeKit/raw/themekit-initial/Imgs/ThemeKit@2x.png" width="377" height="105" alt="ThemeKit" />
</p>

![macOS](https://img.shields.io/badge/os-macOS%2010.10%2B-green.svg?style=flat)
![Swift3](https://img.shields.io/badge/swift-3.2-green.svg?style=flat)
![Release](https://img.shields.io/badge/release-1.0-blue.svg?style=flat)
![MIT](https://img.shields.io/badge/license-MIT-lightgray.svg)
![CocoaPods](https://img.shields.io/badge/dep-CocoaPods-orange.svg)
![Carthage](https://img.shields.io/badge/dep-Carthage-orange.svg)

## Summary

*ThemeKit* is a lightweight theming library completly written in Swift 3.2 that provides theming capabilities to both Swift 3.2/4 and Objective-C macOS applications.

*ThemeKit* is brought to you with ❤️ by [Nuno Grilo](http://nunogrilo.com) and the [Paw](http://paw.cloud) [team](https://github.com/orgs/luckymarmot/people).

<p align="left">
  <img src="https://github.com/luckymarmot/ThemeKit/raw/themekit-initial/Imgs/ThemeKit.gif" width="675" height="390" alt="ThemeKit Animated Demo" />
</p>
Download the [ThemeKit Demo](https://github.com/luckymarmot/ThemeKit/raw/themekit-initial/Demo/Bin/Demo.zip) binary and give it a try!

## Table of Contents
* [Summary](#summary)
* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
  * [Simple Usage](#simple-usage)
  * [Advanced Usage](#advanced-usage)
     * [Observing theme changes](#observing-theme-changes)
     * [Manually theming windows](#manually-theming-windows)
     * [NSWindow extension](#nswindow-extension)
* [Theme-aware Assets](#theme-aware-assets)
* [Creating Themes](#creating-themes)
  * [Native Themes](#native-themes)
  * [User Themes](#user-themes)
* [FAQ](#faq)
* [License](#license)

## Features

- Written in Swift 3.2
- Optional configuration, none required
- Neglected performance impact
- Automatically theme windows (configurable)
- Themes:
  - [`LightTheme`](https://opensource.paw.cloud/themekit/docs/Classes/LightTheme.html) (default macOS appearance)
  - [`DarkTheme`](https://opensource.paw.cloud/themekit/docs/Classes/DarkTheme.html)
  - [`SystemTheme`](https://opensource.paw.cloud/themekit/docs/Classes/SystemTheme.html) (default theme). Dynamically resolves to `ThemeManager.lightTheme` or `ThemeManager.darkTheme`, depending on the *"System Preferences > General > Appearance"*.
  - Support for custom themes ([`Theme`](https://opensource.paw.cloud/themekit/docs/Classes/Theme.html))
  - Support for user-defined themes ([`UserTheme`](https://opensource.paw.cloud/themekit/docs/Classes/UserTheme.html))
- Theme-aware assets:
  - [`ThemeColor`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeColor.html): colors that dynamically change with the theme
  - [`ThemeGradient`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeGradient.html): gradients that dynamically change with the theme
  - [`ThemeImage`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeImage.html): images that dynamically change with the theme
  - Optional override of `NSColor` named colors (e.g., `labelColor`) to dynamically change with the theme

## Installation
There are multiple options to inlcude *ThemeKit* on your project:

- [CocoaPods](https://cocoapods.org): add to your `Podfile`:

  ```
  use_frameworks!
  pod 'ThemeKit', '~> 1.0'
  ```
  
- [Carthage](https://github.com/Carthage/Carthage):

  ```
  github "luckymarmot/ThemeKit"
  ```
  
- Manually:
  - Either add `ThemeKit.framework` on your project
  - Or, manually add source files from the `ThemeKit\` folder to your project

## Usage

### Simple Usage
At its simpler usage, applications can be themed with a single line command:

```swift
func applicationWillFinishLaunching(_ notification: Notification) {
	
	/// Apply the dark theme
	ThemeManager.darkTheme.apply()
	
	/// or, the light theme
	//ThemeManager.lightTheme.apply()
	
	/// or, the 'system' theme, which dynamically changes to light or dark, 
	/// respecting *System Preferences > General > Appearance* setting.
	//ThemeManager.systemTheme.apply()
	
}
```

### Advanced Usage

The following code will define which windows should be automatically themed ([`WindowThemePolicy`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeKit/WindowThemePolicy.html)) and add support for user themes ([`UserTheme`](https://opensource.paw.cloud/themekit/docs/Classes/UserTheme.html)):

```swift
func applicationWillFinishLaunching(_ notification: Notification) {

	/// Define default theme.
	/// Used on first run. Default: `SystemTheme`.
	/// Note: `SystemTheme` is a special theme that resolves to `ThemeManager.lightTheme` or `ThemeManager.darkTheme`,
	/// depending on the macOS preference at 'System Preferences > General > Appearance'.
	ThemeManager.defaultTheme = ThemeManager.lightTheme
	
	/// Define window theme policy.
	ThemeManager.shared.windowThemePolicy = .themeAllWindows
	//ThemeManager.shared.windowThemePolicy = .themeSomeWindows(windowClasses: [MyWindow.self])
	//ThemeManager.shared.windowThemePolicy = .doNotThemeSomeWindows(windowClasses: [NSPanel.self])
	//ThemeManager.shared.windowThemePolicy = .doNotThemeWindows
	    
	/// Enable & configure user themes.
	/// Will use folder `(...)/Application Support/{your_app_bundle_id}/Themes`.
	let applicationSupportURLs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
	let thisAppSupportURL = URL.init(fileURLWithPath: applicationSupportURLs.first!).appendingPathComponent(Bundle.main.bundleIdentifier!)
	let userThemesFolderURL = thisAppSupportURL.appendingPathComponent("Themes")
	ThemeManager.shared.userThemesFolderURL = userThemesFolderURL
	
	/// Change the default light and dark theme, used when `SystemTheme` is selected.
	//ThemeManager.lightTheme = ThemeManager.shared.theme(withIdentifier: PaperTheme.identifier)!
	//ThemeManager.darkTheme = ThemeManager.shared.theme(withIdentifier: "com.luckymarmot.ThemeKit.PurpleGreen")!
	
	/// Apply last applied theme (or the default theme, if no previous one)
	ThemeManager.shared.applyLastOrDefaultTheme()
	 
}    
```

#### Observing theme changes

ThemeKit provides the following notifications:

- `Notification.Name.willChangeTheme` is sent when current theme is about to change
- `Notification.Name.didChangeTheme` is sent when current theme did change
- `Notification.Name.didChangeSystemTheme` is sent when system theme did change (System Preference > General)

Example:

```swift
// Register to be notified of theme changes
NotificationCenter.default.addObserver(self, selector: #selector(changedTheme(_:)), name: .didChangeTheme, object: nil)

@objc private func changedTheme(_ notification: Notification) {
	// ...
}
```

Additionaly, the following properties are KVO compliant:

- [`ThemeManager.shared.theme`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeManager.html#/s:vC8ThemeKit12ThemeManager6themesGSaPS_5Theme__)
- [`ThemeManager.shared.effectiveTheme`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeManager.html#/s:vC8ThemeKit12ThemeManager14effectiveThemePS_5Theme_)
- [`ThemeManager.shared.themes`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeManager.html#/s:vC8ThemeKit12ThemeManager6themesGSaPS_5Theme__)
- [`ThemeManager.shared.userThemes`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeManager.html#/s:vC8ThemeKit12ThemeManager10userThemesGSaPS_5Theme__)

Example:

```swift
// Register for KVO changes on ThemeManager.shared.effectiveTheme
ThemeManager.shared.addObserver(self, forKeyPath: "effectiveTheme", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)

public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
	if keyPath == "effectiveTheme" {
		// ...
   }
}
```


#### Manually theming windows

In case ([`WindowThemePolicy`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeKit/WindowThemePolicy.html)) was NOT set to `.themeAllWindows`, you may need to manually theme a window. You can use our `NSWindow` extension for that:

##### NSWindow Extension

- `NSWindow.theme()`

	Theme window if appearance needs update. Doesn't check for policy compliance.


- `NSWindow.isCompliantWithWindowThemePolicy()`

	Check if window complies to current policy.

- `NSWindow.themeIfCompliantWithWindowThemePolicy()`

	Theme window if compliant to `ThemeManager.shared.windowThemePolicy` (and if appearance needs update).

- `NSWindow.themeAllWindows()`

	Theme all windows compliant to `ThemeManager.shared.windowThemePolicy` (and if appearance needs update).
	
- `NSWindow.windowTheme`

	Any window specific theme.
   This is, usually, `nil`, which means the current global theme will be used.
   Please note that when using window specific themes, only the associated `NSAppearance` will be automatically set. All theme aware assets (`ThemeColor`, `ThemeGradient` and `ThemeImage`) should call methods that returns a resolved color instead (which means they don't change with the theme change, you need to observe theme changes manually, and set colors afterwards):

   	- `ThemeColor.color(for view:, selector:)`
   	- `ThemeGradient.gradient(for view:, selector:)`
   	- `ThemeImage.image(for view:, selector:)`

   	Additionaly, please note that system overriden colors (`NSColor.*`) will always use the global theme.

- `NSWindow.windowEffectiveTheme`

	Returns the current effective theme (read-only).

- `NSWindow.windowEffectiveThemeAppearance`

	Returns the current effective appearance (read-only).


## Theme-aware Assets

[`ThemeColor`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeColor.html), [`ThemeGradient`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeGradient.html) and [`ThemeImage`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeImage.html) provides colors, gradients and images, respectively, that dynamically change with the current theme.

Additionally, named colors from the `NSColor` class defined on the `ThemeColor` subclass extension will override the system ones, providing theme-aware colors.

For example, a project defines a `ThemeColor.brandColor` color. This will resolve to different colors at runtime, depending on the selected theme:

- `ThemeColor.brandColor` will resolve to `NSColor.blue` if the light theme is selected
- `ThemeColor.brandColor` will resolve to `NSColor.white` if the dark theme is selected
- `ThemeColor.brandColor` will resolve to `rgba(100, 50, 0, 0.5)` for some user-defined theme ([`UserTheme`](https://opensource.paw.cloud/themekit/docs/Classes/UserTheme.html))

Similarly, defining a `ThemeColor.labelColor` will override `NSColor.labelColor` (`ThemeColor` is a subclass of `NSColor`), and *ThemeKit* will allow `labelColor` to be customized on a per-theme basis as well.

### Fallback Assets

ThemeKit provides a simple fallback mechanism when looking up assets in current theme. It will search for assets, in order:

- the asset name, defined in theme (e.g., `myBackgroundColor`)
- `fallbackForegroundColor`, `fallbackBackgroundColor`, `fallbackGradient` or `fallbackImage` defined in theme, depending if asset is a foreground/background color, gradient or image, respectively
- `defaultFallbackForegroundColor`, `defaultFallbackBackgroundColor`, `fallbackGradient` or `defaultFallbackImage` defined internally, depending if asset is a foreground/background color, gradient or image, respectively

However, for overrided system named colors, the fallback mechanism is different and simpler:

- the asset name, defined in theme (e.g., `labelColor`)
- original asset defined in system (e.g., `NSColor.labelColor`)

Please refer to [`ThemeColor`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeColor.html), [`ThemeGradient`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeGradient.html) and [`ThemeImage`](https://opensource.paw.cloud/themekit/docs/Classes/ThemeImage.html) for more information.

## Creating Themes

### Native Themes
For creating additional themes, you only need to create a class that conforms to the [`Theme`](https://opensource.paw.cloud/themekit/docs/Classes/Theme.html) protocol and extends `NSObject`.

Sample theme:

```swift
import Cocoa
import ThemeKit
	
class MyOwnTheme: NSObject, Theme {
    
    /// Light theme identifier (static).
    public static var identifier: String = "com.luckymarmot.ThemeKit.MyOwnTheme"
    
    /// Unique theme identifier.
    public var identifier: String = MyOwnTheme.identifier
    
    /// Theme display name.
    public var displayName: String = "My Own Theme"
    
    /// Theme short display name.
    public var shortDisplayName: String = "My Own"
    
    /// Is this a dark theme?
    public var isDarkTheme: Bool = false
    
    /// Description (optional).
    public override var description : String {
        return "<\(MyOwnTheme.self): \(themeDescription(self))>"
    }
    
    // MARK: -
    // MARK: Theme Assets
    
    // Here you can define the instance methods for the class methods defined 
    // on `ThemeColor`, `ThemeGradient` and `ThemeImage`, if any. Check
    // documentation of these classes for more details.
}
```

### User Themes
ThemeKit also supports definition of additional themes with simple text files (`.theme` files). Example of a very basic `.theme` file:

```ruby
// ************************* Theme Info ************************* //
displayName = My Theme 1
identifier = com.luckymarmot.ThemeKit.MyTheme1
darkTheme = true

// ********************* Colors & Gradients ********************* //
# define color for `ThemeColor.brandColor`
brandColor = $blue
# define a new color for `NSColor.labelColor` (overriding)
labelColor = rgb(11, 220, 111)
# define gradient for `ThemeGradient.brandGradient`
brandGradient = linear-gradient($orange.sky, rgba(200, 140, 60, 1.0))
 
// ********************* Images & Patterns ********************** //
# define pattern image from named image "paper" for color `ThemeColor.contentBackgroundColor`
contentBackgroundColor = pattern(named:paper)
# define pattern image from filesystem (relative to user themes folder) for color `ThemeColor.bottomBackgroundColor`
bottomBackgroundColor = pattern(file:../some/path/some-file.png)
# define image using named image "apple"
namedImage = image(named:apple)
# define image using from filesystem (relative to user themes folder)
fileImage = image(file:../some/path/some-file.jpg)

// *********************** Common Colors ************************ //
blue = rgb(0, 170, 255)
orange.sky = rgb(160, 90, 45, .5)

// ********************** Fallback Assets *********************** //
fallbackForegroundColor = rgb(255, 10, 90, 1.0)
fallbackBackgroundColor = rgb(255, 200, 190)
fallbackGradient = linear-gradient($blue, rgba(200, 140, 60, 1.0))

```

To enable support for user themes, just need to set the location for them:

```swift
// Setup ThemeKit user themes folder
ThemeManager.shared.userThemesFolderURL = //...
```

Please refer to [`UserTheme`](https://opensource.paw.cloud/themekit/docs/Classes/UserTheme.html) for more information.


## FAQ

### **Can the window titlebar/toolbar/tabbar be themed?**
Yes - please check one way to do it on the Demo project.

### **Can controls be tinted with different colors?**
Other than the colors set by the inherited appearance - light (dark text on light background) or dark (light text on dark background) - natively, it is not possible to specify different colors for the text and/or background fills of controls (buttons, popups, etc).

For simple cases, overriding `NSColor` can be sufficient: for example, `NSColor.labelColor` is a named color used for text labels; overriding it will allow to have all labels themed accordingly. You can get a list of all overridable named colors (class method names) with `NSColor.colorMethodNames()`.

For more complex cases, like views/controls with custom drawing, please refer to next question.

### **Can I make custom drawing views/controls theme-aware?**
Yes, you can! Implement your own custom controls drawing using [Theme-aware Assets](#theme-aware-assets) (`ThemeColor` and `ThemeGradient`) so that your controls drawing will always adapt to your current theme... automatically!

In case needed (for example, if drawing is being cached), you can observe when theme changes to refresh the UI or to perform any theme related operation. Check *"Observing theme changes"* on [Usage](#usage) section above.

### **Scrollbars appear all white on dark themes!**
If the user opts for always showing the scrollbars on *System Preferences*, scrollbars may render all white on dark themes. To bypass this, we need to observe for theme changes and change its background color directly. E.g.,

   ```swift
   scrollView?.backgroundColor = ThemeColor.myBackgroundColor
   scrollView?.wantsLayer = true
   NotificationCenter.default.addObserver(forName: .didChangeTheme, object: nil, queue: nil) { (note) in
     scrollView?.verticalScroller?.layer?.backgroundColor = ThemeColor.myBackgroundColor.cgColor
   }
   ```

### **I'm having font smoothing issues!**
You may run into font smoothing issues, when you use text without a background color set. Bottom line is, always specify/draw a background when using/drawing text. 

  1. For controls like `NSTextField`, `NSTextView`, etc:
   
    Specify a background color on the control. E.g.,
    
    ```swift
    control.backgroundColor = NSColor.black
    ```
    
  2. For custom text rendering:

    First draw a background fill, then enable font smoothing and render your text. E.g.,
    
    ```swift
    let context = NSGraphicsContext.current()?.cgContext
    NSColor.black.set()
    context?.fill(frame)
    context?.saveGState()
    context?.setShouldSmoothFonts(true)
        
    // draw text...
    
	context?.restoreGState()
    ``` 
    As a last solution - if you really can't draw a background color - you can disable font smoothing which can slightly improve text rendering:
    
    ```swift
    let context = NSGraphicsContext.current()?.cgContext
    context?.saveGState()
    context?.setShouldSmoothFonts(false)
        
    // draw text...
    
	context?.restoreGState()
   ```
   
  3. For custom `NSButton`'s:

    This is more tricky, as you will need to override private methods. If you are distributing your app on the Mac App Store, you must first check if this is allowed.
    
    a) override the private method `_backgroundColorForFontSmoothing` to return your button background color.
    
    b) if (a) isn't sufficient, you will also need to override `_textAttributes` and change the dictionary returned from the `super` call to provide your background color for the key `NSBackgroundColorAttributeName`.

## License

*ThemeKit* is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
