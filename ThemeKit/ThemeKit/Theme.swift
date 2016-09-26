//
//  Theme.swift
//  CoreColor
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/// Theme protocol. All themes conforms to this.
@objc(TKTheme)
public protocol Theme {
    // MARK: Required
    
    /// Unique theme identifier.
    var identifier: String { get }
    
    /// Theme display name.
    var displayName: String { get }
    
    /// Theme short display name.
    var shortDisplayName: String { get }
    
    /// Is this a dark theme?
    var isDarkTheme: Bool { get }
    
    
    // MARK: Optional
    
    /// Theme asset for the specified key.
    @objc optional func themeAsset(_ key: String) -> Any?
    
    /// Foreground color to be used on fallback situations.
    @objc optional var fallbackForegroundColor : NSColor? { get }
    
    /// Background color to be used on fallback situations.
    @objc optional var fallbackBackgroundColor : NSColor? { get }
    
    /// Gradient to be used on fallback situations.
    @objc optional var fallbackGradient : NSGradient? { get }
}

/// Theme protocol extension.
public extension Theme {
    
    /// Is this a light theme?
    public var isLightTheme: Bool {
        return !isDarkTheme
    }
    
    /// Does theme automatically resolve to LightTheme or DarkTheme,
    /// accordingly to System Preferences > General?
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
    /// no `fallbackBackgroundColor` was specified by the theme.
    var defaultFallbackBackgroundColor: NSColor {
        return isLightTheme ? NSColor.white : NSColor.black
    }
    
    /// Default gradient to be used on fallback situations when
    /// no `fallbackForegroundColor` was specified by the theme.
    var defaultFallbackGradient: NSGradient {
        return NSGradient.init(starting: defaultFallbackBackgroundColor, ending: defaultFallbackBackgroundColor)!
    }
    
    /// Effective theme, which can be different from itself if it represents the 
    /// system theme (in that case it will be either `LightTheme` or `DarkTheme`).
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
