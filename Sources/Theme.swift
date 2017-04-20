//
//  Theme.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/**
 Theme protocol: the base of all themes.
 
 *ThemeKit* makes available, without any further coding:
 
 - a `LightTheme` (the default macOS theme)
 - a `DarkTheme` (the dark macOS theme, using `NSAppearanceNameVibrantDark`)
 - a `SystemTheme` (which dynamically resolve to either `LightTheme` or `DarkTheme 
   depending on the macOS preference at **System Preferences > General > Appearance**)
 
 You can choose wheter or not to use these, and you can also implement your custom
 themes by:
 
 - implementing native `Theme` classes conforming to this protocol and `NSObject`
 - provide user themes (`UserTheme`) with `.theme` files
 
 Please check the provided *Demo.app* project for sample implementations of both.
 
 */
@objc(TKTheme)
public protocol Theme: NSObjectProtocol {
    // MARK: Required Properties
    
    /// Unique theme identifier.
    var identifier: String { get }
    
    /// Theme display name.
    var displayName: String { get }
    
    /// Theme short display name.
    var shortDisplayName: String { get }
    
    /// Is this a dark theme?
    var isDarkTheme: Bool { get }
    
    
    // MARK: Optional Methods/Properties
    
    /// Optional: theme asset for the specified key (`ThemeColor`, `ThemeGradient`,
    /// `ThemeImage` and, for `UserTheme`s only, also `String`).
    @objc optional func themeAsset(_ key: String) -> Any?
    
    /// Optional: foreground color to be used on when a foreground color is not provided
    /// by the theme.
    @objc optional var fallbackForegroundColor : NSColor? { get }
    
    /// Optional: background color to be used on when a background color (a color which
    /// contains `Background` in its name) is not provided by the theme.
    @objc optional var fallbackBackgroundColor : NSColor? { get }
    
    /// Optional: gradient to be used on when a gradient is not provided by the theme.
    @objc optional var fallbackGradient : NSGradient? { get }
    
    /// Optional: image to be used on when an image is not provided by the theme.
    @objc optional var fallbackImage : NSImage? { get }
}

/// Theme protocol extension.
///
/// These functions are available for all `Theme`s.
public extension Theme {
    
    // MARK: Convenient Methods/Properties
    
    /// Is this a light theme?
    public var isLightTheme: Bool {
        return !isDarkTheme
    }
    
    /// Does theme automatically resolve to `ThemeManager.lightTheme` or 
    /// `ThemeManager.darkTheme`, accordingly to **System Preferences > General > Appearance**?
    public var isAutoTheme: Bool {
        return identifier == SystemTheme.identifier
    }
    
    /// Apply theme (make it the current one).
    public func apply() {
        ThemeManager.shared.theme = self
    }
    
    /// Default foreground color to be used on fallback situations when
    /// no `fallbackForegroundColor` was specified by the theme.
    var defaultFallbackForegroundColor: NSColor {
        return isLightTheme ? NSColor.black : NSColor.white
    }
    
    /// Default background color to be used on fallback situations when
    /// no `fallbackBackgroundColor` was specified by the theme (background color
    /// is a color method that contains `Background` in its name).
    var defaultFallbackBackgroundColor: NSColor {
        return isLightTheme ? NSColor.white : NSColor.black
    }
    
    /// Default gradient to be used on fallback situations when
    /// no `fallbackForegroundColor` was specified by the theme.
    var defaultFallbackGradient: NSGradient {
        return NSGradient(starting: defaultFallbackBackgroundColor, ending: defaultFallbackBackgroundColor)!
    }
    
    /// Default image to be used on fallback situations when
    /// no image was specified by the theme.
    var defaultFallbackImage: NSImage {
        return NSImage(size: NSZeroSize)
    }
    
    /// Effective theme, which can be different from itself if it represents the 
    /// system theme, respecting **System Preferences > General > Appearance** 
    /// (in that case it will be either `ThemeManager.lightTheme` or `ThemeManager.darkTheme`).
    var effectiveTheme: Theme {
        if isAutoTheme {
            return isDarkTheme ? ThemeManager.darkTheme : ThemeManager.lightTheme
        }
        else {
            return self
        }
    }
    
    /// Theme description.
    public func themeDescription(_ theme: Theme) -> String {
        return "\"\(displayName)\" [\(identifier)]\(isDarkTheme ? " (Dark)" : "")"
    }
}

/// Check if themes are the same.
func == (lhs: Theme, rhs: Theme) -> Bool {
    return lhs.identifier == rhs.identifier
}

/// Check if themes are different.
func != (lhs: Theme, rhs: Theme) -> Bool {
    return lhs.identifier != rhs.identifier
}
