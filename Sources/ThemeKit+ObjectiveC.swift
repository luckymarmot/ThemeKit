//
//  ThemeKit+ObjectiveC.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

public extension ThemeKit {
    
    /// Window theme policies that define which windows should be automatically themed, if any (Objective-C variant, only).
    @objc(TKThemeKitWindowThemePolicy)
    public enum TKThemeKitWindowThemePolicy: Int {
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
    public var objc_windowThemePolicy: TKThemeKitWindowThemePolicy {
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
                windowThemePolicy = .themeSomeWindows(windowClasses: objc_themableWindowClasses ?? [])
            case .doNotThemeSomeWindows:
                windowThemePolicy = .doNotThemeSomeWindows(windowClasses: objc_notThemableWindowClasses ?? [])
            case .doNotThemeWindows:
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
    /// Windows classes to be excluded from theming with the `TKThemeKitWindowThemePolicyDoNotThemeSomeWindows` (Objective-C only).
    @objc(notThemableWindowClasses)
    public var objc_notThemableWindowClasses: [AnyClass]? {
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
    
    /// Windows classes to be themed with the `TKThemeKitWindowThemePolicyThemeSomeWindows` (Objective-C only).
    @objc(themableWindowClasses)
    public var objc_themableWindowClasses: [AnyClass]? {
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
