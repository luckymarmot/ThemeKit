//
//  ThemeColor+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import ThemeKit

extension ThemeColor {
    
    // MARK: CONTENT
    
    /// Notes content title text color
    static var contentTitleColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    /// Notes text foreground color
    static var contentTextColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    /// Notes text background color
    static var contentBackgroundColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    
    // MARK: DETAILS
    
    /// Notes details title text color
    static var detailsTitleColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    /// Notes details background color
    static var detailsBackgroundColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    
    // MARK: SYSTEM OVERRIDE
    
    override open static var labelColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    override open static var secondaryLabelColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
}
