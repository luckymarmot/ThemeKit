//
//  LightTheme+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import ThemeKit

extension LightTheme {
    
    /// Notes text foreground color
    var contentTextColor: NSColor {
        return NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }
    
    /// Notes text background color
    var contentBackgroundColor: NSColor {
        return NSColor.white
    }
    
//    var brandGradient: NSGradient? {
//        return NSGradient(starting: brandColor, ending: NSColor.black)
//    }
    
}
