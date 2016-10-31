//
//  ThemeManager+ObjectiveC.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

public extension ThemeManager {
    
    /// Window theme policies that define which windows should be automatically themed, if any (Objective-C variant, only).
    @objc(TKThemeManagerWindowThemePolicy)
    public enum TKThemeManagerWindowThemePolicy: Int {
        /// Theme all application windows (default).
        case themeAllWindows
        /// Only theme windows of the specified classes.
        case themeSomeWindows
        /// Do not theme windows of the specified classes.
        case doNotThemeSomeWindows
        /// Do not theme any window.
        case doNotThemeWindows
    }
    
    /// Current window theme policy.
    @objc(windowThemePolicy)
    public var objc_windowThemePolicy: TKThemeManagerWindowThemePolicy {
        get {
            switch windowThemePolicy {
                
            case .themeAllWindows:
                return .themeAllWindows
                
            case .themeSomeWindows:
                return .themeSomeWindows
                
            case .doNotThemeSomeWindows:
                return .doNotThemeSomeWindows
                
            case .doNotThemeWindows:
                return .doNotThemeWindows
            }
        }
        set(value) {
            switch value {
            case .themeAllWindows:
                windowThemePolicy = .themeAllWindows
            case .themeSomeWindows:
                windowThemePolicy = .themeSomeWindows(windowClasses: themableWindowClasses ?? [])
            case .doNotThemeSomeWindows:
                windowThemePolicy = .doNotThemeSomeWindows(windowClasses: notThemableWindowClasses ?? [])
            case .doNotThemeWindows:
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
    /// Windows classes to be excluded from theming with the `TKThemeManagerWindowThemePolicyDoNotThemeSomeWindows`.
    @objc(notThemableWindowClasses)
    public var notThemableWindowClasses: [AnyClass]? {
        get {
            switch windowThemePolicy {
                
            case .themeAllWindows:
                return nil
                
            case .themeSomeWindows:
                return []
                
            case .doNotThemeSomeWindows(let windowClasses):
                return windowClasses
                
            case .doNotThemeWindows:
                return []
            }
        }
        set(value) {
            if value == nil {
                windowThemePolicy = .themeAllWindows
            }
            else if value!.count > 0 {
                windowThemePolicy = .doNotThemeSomeWindows(windowClasses: value!)
            }
            else {
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
    /// Windows classes to be themed with the `TKThemeManagerWindowThemePolicyThemeSomeWindows`.
    @objc(themableWindowClasses)
    public var themableWindowClasses: [AnyClass]? {
        get {
            switch windowThemePolicy {
                
            case .themeAllWindows:
                return nil
                
            case .themeSomeWindows(let windowClasses):
                return windowClasses
                
            case .doNotThemeSomeWindows:
                return []
                
            case .doNotThemeWindows:
                return []
            }
        }
        set(value) {
            if value == nil {
                windowThemePolicy = .themeAllWindows
            }
            else if value!.count > 0 {
                windowThemePolicy = .themeSomeWindows(windowClasses: value!)
            }
            else {
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
}
