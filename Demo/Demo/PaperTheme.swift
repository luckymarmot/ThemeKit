//
// PaperTheme.swift
//  Demo
//
//  Created by Nuno Grilo on 01/10/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa
import ThemeKit

class PaperTheme: NSObject, Theme {
    
    /// Light theme identifier (static).
    public static var identifier: String = "com.luckymarmot.ThemeKit.PaperTheme"
    
    /// Unique theme identifier.
    public var identifier: String = PaperTheme.identifier
    
    /// Theme display name.
    public var displayName: String = "Paper Theme"
    
    /// Theme short display name.
    public var shortDisplayName: String = "Paper"
    
    /// Is this a dark theme?
    public var isDarkTheme: Bool = false
    
    /// Description.
    public override var description : String {
        return "<\(PaperTheme.self): \(themeDescription(self))>"
    }
    
    // MARK: -
    // MARK: Theme Assets
    
    // MARK: WINDOW
    
    var windowTitleBarActiveColor: NSColor {
       if _windowTitleBarActiveColor == nil,
          let paperImage = self.paperImage {
            // darken paper image
            paperImage.lockFocus()
            NSColor.init(white: 0.0, alpha: 0.05).setFill()
            NSBezierPath(rect: NSMakeRect(0, 0, paperImage.size.width, paperImage.size.height)).fill()
            paperImage.unlockFocus()
            
            _windowTitleBarActiveColor = NSColor(patternImage: paperImage)
        }
        
        return _windowTitleBarActiveColor ?? defaultFallbackBackgroundColor
    }
    private var _windowTitleBarActiveColor: NSColor?
    
    var windowTitleBarInactiveColor: NSColor {
        guard let paperImage = self.paperImage else {
            return defaultFallbackBackgroundColor
        }
        return NSColor(patternImage: paperImage)
    }
    
    
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
        if _contentBackgroundColor == nil,
           let paperImage = self.paperImage {
            // lighten paper image
            paperImage.lockFocus()
            NSColor.init(white: 1.0, alpha: 0.5).setFill()
            NSBezierPath(rect: NSMakeRect(0, 0, paperImage.size.width, paperImage.size.height)).fill()
            paperImage.unlockFocus()
            
            _contentBackgroundColor = NSColor(patternImage: paperImage)
        }
        
        return _contentBackgroundColor ?? defaultFallbackBackgroundColor
    }
    private var _contentBackgroundColor: NSColor?
    
    /// Rainbow gradient (used between title and text)
    var rainbowGradient: NSGradient? {
        let blue = NSColor(calibratedRed: 0.18, green: 0.45, blue: 0.88, alpha: 1.0)
        let clear = NSColor(calibratedWhite: 1.0, alpha: 0.0)
        return NSGradient(colorsAndLocations: (blue, 0.0), (clear, 0.66))
    }
    
    
    // MARK: DETAILS
    
    /// Notes details title text color
    var detailsTitleColor: NSColor {
        return contentTitleColor
    }
    
    /// Notes details background color
    var detailsBackgroundColor: NSColor {
        guard let paperImage = self.paperImage else {
            return defaultFallbackBackgroundColor
        }
        return NSColor(patternImage: paperImage)
    }
    
    /// Notes details image
    var detailsImage: NSImage? {
        return NSImage(named: "file_doc")
    }
    
    
    // MARK: SYSTEM OVERRIDE
    
    var secondaryLabelColor: NSColor {
        return NSColor(calibratedRed: 0.18, green: 0.45, blue: 0.88, alpha: 1.0)
    }
    
    
    // MARK: SHARED
    
    var paperImage: NSImage? {
        return Bundle.main.image(forResource: "paper")
    }
    
}
