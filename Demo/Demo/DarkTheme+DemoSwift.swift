//
//  DarkTheme+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import ThemeKit

extension DarkTheme {
    
    // MARK: CONTENT
    
    /// Notes content title text color
    var contentTitleColor: NSColor {
        return NSColor(calibratedWhite: 0.95, alpha: 1.0)
    }
    
    /// Notes text foreground color
    var contentTextColor: NSColor {
        return NSColor.lightGray
    }
    
    /// Notes text background color
    var contentBackgroundColor: NSColor {
        return NSColor.black
    }
    
    var rainbowGradient: NSGradient? {
        return NSGradient(starting: NSColor.green, ending: NSColor.blue)
    }
    
    
    // MARK: DETAILS
    
    /// Notes content title text color
    var detailsTitleColor: NSColor {
        return NSColor.lightGray
    }
    
}
