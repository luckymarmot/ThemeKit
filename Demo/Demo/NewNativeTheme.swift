//
// NewNativeTheme.swift
//  Demo
//
//  Created by Nuno Grilo on 01/10/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class NewNativeTheme: NSObject, Theme {
    
    /// Light theme identifier (static).
    public static var identifier: String = "com.luckymarmot.ThemeKit.NewNativeTheme"
    
    /// Unique theme identifier.
    public var identifier: String = NewNativeTheme.identifier
    
    /// Theme display name.
    public var displayName: String = "Theme Subclass"
    
    /// Theme short display name.
    public var shortDisplayName: String = "Theme Subclass"
    
    /// Is this a dark theme?
    public var isDarkTheme: Bool = false
    
    /// Description.
    public override var description : String {
        return "<\(NewNativeTheme.self): \(themeDescription(self))>"
    }
    
    // MARK: -
    // MARK: Theme Assets
    
    // MARK: CONTENT
    
    /// Notes content title text color
    var contentTitleColor: NSColor {
        return NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.35, alpha: 1.0)
    }
    
    /// Notes text foreground color
    var contentTextColor: NSColor {
        return NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
    }
    
    /// Notes text background color
    var contentBackgroundColor: NSColor {
        return NSColor(red:0.70, green:0.69, blue:0.98, alpha:1.0)
    }
    
    /// Rainbow gradient (used between title and text)
    var rainbowGradient: NSGradient? {
        return NSGradient(starting: NSColor(calibratedRed: 0.0, green: 0.66, blue: 0.7, alpha: 1.0), ending: ThemeColor.contentBackgroundColor)
    }
    
    
    // MARK: DETAILS
    
    /// Notes details title text color
    var detailsTitleColor: NSColor {
        return NSColor(red:0.43, green:0.43, blue:0.73, alpha:1.0)
    }
    
    /// Details vertical gradient
    var detailsGradient: NSGradient? {
        return NSGradient(starting: NSColor(calibratedRed: 0.0, green: 0.66, blue: 0.7, alpha: 1.0), ending: NSColor(calibratedWhite: 1.0, alpha: 0.0))
    }
    
}
