//
//  NotificationName+ThemeKit.swift
//  CoreColor
//
//  Created by Nuno Grilo on 07/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    /// ThemeKit notification sent when current theme is about to change.
    public static let willChangeTheme = Notification.Name("ThemeKitWillChangeThemeNotification")
    
    /// ThemeKit notification sent when current theme did change.
    public static let didChangeTheme = Notification.Name("ThemeKitDidChangeThemeNotification")
    
    /// ThemeKit notification sent when system theme did change (System Preference > General).
    public static let didChangeSystemTheme = Notification.Name("ThemeKitDidChangeSystemThemeNotification")
    
    /// ThemeKit notification sent when an NSWindow is about to be shown.
    public static let willShowWindow = Notification.Name("ThemeKitWindowWillShowNotification")
    
    /// System notification sent when System Preference for dark mode changes.
    static let didChangeAppleInterfaceTheme = Notification.Name("AppleInterfaceThemeChangedNotification")
}
