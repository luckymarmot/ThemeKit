//
//  LightTheme+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Foundation
import ThemeKit

extension LightTheme {

    // MARK: CONTENT

    /// Notes content title text color
    @objc var contentTitleColor: NSColor {
        return NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    }

    /// Notes text foreground color
    @objc var contentTextColor: NSColor {
        return NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }

    /// Notes text background color
    @objc var contentBackgroundColor: NSColor {
        return NSColor(red: 1.0, green: 0.99, blue: 0.98, alpha: 1.0)
    }

    /// Rainbow gradient (used between title and text)
    @objc var rainbowGradient: NSGradient? {
        return NSGradient(starting: NSColor(calibratedRed: 0.0, green: 0.66, blue: 1.0, alpha: 1.0), ending: ThemeColor.contentBackgroundColor)
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
        return NSImage(named: NSImage.Name("sun"))
    }

}
