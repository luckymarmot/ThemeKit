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
    
    var brandColor: NSColor {
        return NSColor.orange
    }
    
    var labelColor: NSColor {
        return NSColor.blue
    }
    
    var brandGradient: NSGradient? {
        return NSGradient(starting: brandColor, ending: NSColor.black)
    }
    
}
