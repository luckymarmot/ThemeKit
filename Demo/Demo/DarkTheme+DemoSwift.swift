//
//  DarkTheme+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Foundation
import ThemeKit

extension DarkTheme {

    // MARK: CONTENT

    /// Notes content title text color
    @objc var contentTitleColor: NSColor {
        return NSColor(calibratedWhite: 0.95, alpha: 1.0)
    }

    /// Notes text foreground color
    @objc var contentTextColor: NSColor {
        return NSColor.lightGray
    }

    /// Notes text background color
    @objc var contentBackgroundColor: NSColor {
        return NSColor.black
    }

    /// Rainbow gradient (used between title and text)
    @objc var rainbowGradient: NSGradient? {
        return NSGradient(starting: NSColor.green, ending: NSColor.blue)
    }

    // MARK: DETAILS

    /// Notes details title text color
    @objc var detailsTitleColor: NSColor {
        return NSColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 1.0)
    }

    /// Notes details background color
    @objc var detailsBackgroundColor: NSColor {
        return NSColor(calibratedWhite: 1.0, alpha: 0.0)
    }

    /// Notes details image
    @objc var detailsImage: NSImage? {
        return NSImage(named: NSImage.Name("moon"))
    }

}
