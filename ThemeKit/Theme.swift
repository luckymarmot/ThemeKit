//
//  Theme.swift
//  CoreColor
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/// Theme protocol. The base of all themes.
@objc(TKTheme)
public protocol Theme {
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
    
    /// Theme asset for the specified key (`ThemeColor`, `ThemeGradient` and 
    /// for `UserTheme`s only, also `String`).
    @objc optional func themeAsset(_ key: String) -> Any?
    
    /// Foreground color to be used on when a foreground color is not provided 
    /// by the theme.
    @objc optional var fallbackForegroundColor : NSColor? { get }
    
    /// Background color to be used on when a background color (a color which 
    /// contains `Background` in its name) is not provided by the theme.
    @objc optional var fallbackBackgroundColor : NSColor? { get }
    
    /// Gradient to be used on when a gradient is not provided by the theme.
    @objc optional var fallbackGradient : NSGradient? { get }
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
    
    /// Does theme automatically resolve to `ThemeKit.lightTheme` or 
    /// `ThemeKit.darkTheme`, accordingly to **System Preferences > General > Appearance**?
    public var isAutoTheme: Bool {
        return identifier == SystemTheme.identifier
    }
    
    /// Apply theme (make it the current one).
    public func apply() {
        ThemeKit.shared.theme = self
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
        return NSGradient.init(starting: defaultFallbackBackgroundColor, ending: defaultFallbackBackgroundColor)!
    }
    
    /// Effective theme, which can be different from itself if it represents the 
    /// system theme, respecting **System Preferences > General > Appearance** 
    /// (in that case it will be either `ThemeKit.lightTheme` or `ThemeKit.darkTheme`).
    var effectiveTheme: Theme {
        if isAutoTheme {
            return isDarkTheme ? ThemeKit.darkTheme : ThemeKit.lightTheme
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
