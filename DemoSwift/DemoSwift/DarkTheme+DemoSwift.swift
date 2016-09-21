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
    
    var brandColor: NSColor {
        return NSColor.lightGray
    }
    
    var brandGradient: NSGradient? {
        return NSGradient(starting: brandColor, ending: NSColor.blue)
    }
}
