//
//  TitleBarOverlayView.swift
//  Demo
//
//  Created by Nuno Grilo on 11/07/2017.
//  Copyright © 2017 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class TitleBarOverlayView: NSView {
    
    /// Drawing code
    override func draw(_ dirtyRect: NSRect) {
        let windowIsActive = window?.isKeyWindow ?? false
        let isWindowInFullScreen = window?.styleMask.contains(.fullScreen) ?? false
                                || (window?.className ?? "") == "NSToolbarFullScreenWindow"
        
        if (windowIsActive || isWindowInFullScreen),
            let color = ThemeManager.shared.theme.themeAsset?("windowTitleBarActiveColor") as? NSColor {
            // Fill with 'active' color
            color.set()
            NSBezierPath(rect: bounds).fill()
        }
        else if !windowIsActive,
            let color = ThemeManager.shared.theme.themeAsset?("windowTitleBarInactiveColor") as? NSColor {
            // Fill with 'inactive' color
            color.set()
            NSBezierPath(rect: bounds).fill()
        }
    }
    
}
