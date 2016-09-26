//
//  ThemeKit+ObjectiveC.swift
//  CoreColor
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
        /// Only theme windows of the specified class names.
        case themeSomeWindows
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
                
            case .doNotThemeWindows:
                return .doNotThemeWindows
            }
        }
        set(value) {
            switch value {
            case .themeAllWindows:
                windowThemePolicy = .themeAllWindows
            case .themeSomeWindows:
                windowThemePolicy = .themeSomeWindows(windowClassNames: objc_themableWindowClassNames ?? [])
            case .doNotThemeWindows:
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
    /// Windows class names to be themed with the `TKThemeKitWindowThemePolicyThemeSomeWindows` (Objective-C only).
    @objc(themableWindowClassNames)
    public var objc_themableWindowClassNames: [String]? {
        get {
            switch windowThemePolicy {
                
            case .themeAllWindows:
                return nil
                
            case .themeSomeWindows(let windowClassNames):
                return windowClassNames
                
            case .doNotThemeWindows:
                return []
            }
        }
        set(value) {
            if value == nil {
                windowThemePolicy = .themeAllWindows
            }
            else if value!.count > 0 {
                windowThemePolicy = .themeSomeWindows(windowClassNames: value!)
            }
            else {
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }
    
}
