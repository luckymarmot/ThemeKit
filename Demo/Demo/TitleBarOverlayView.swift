//
//  TitleBarOverlayView.swift
//  Demo
//
//  Created by Nuno Grilo on 11/07/2017.
//  Copyright © 2017 Paw & Nuno Grilo. All rights reserved.
//

import Cocoa
import ThemeKit

class TitleBarOverlayView: NSView {

    /// Drawing code
    override func draw(_ dirtyRect: NSRect) {
        let theme = ThemeManager.shared.theme
        let windowIsActive = window?.isKeyWindow ?? false
        let isWindowInFullScreen = window?.styleMask.contains(NSWindow.StyleMask.fullScreen) ?? false
                                || (window?.className ?? "") == "NSToolbarFullScreenWindow"

        if (windowIsActive || isWindowInFullScreen),
            let color = theme.themeAsset("windowTitleBarActiveColor") as? NSColor {
            // Fill with 'active' color
            color.set()
            NSBezierPath(rect: bounds).fill()
        } else if !windowIsActive,
            let color = theme.themeAsset("windowTitleBarInactiveColor") as? NSColor {
            // Fill with 'inactive' color
            color.set()
            NSBezierPath(rect: bounds).fill()
        }
    }

}
