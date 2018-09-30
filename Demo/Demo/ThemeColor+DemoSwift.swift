//
//  ThemeColor+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Foundation
import ThemeKit

extension ThemeColor {

    // MARK: WINDOW

    /// Active window title bar color
    @objc static var windowTitleBarActiveColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    /// Inactive window title bar color
    @objc static var windowTitleBarInactiveColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    // MARK: CONTENT

    /// Notes content title text color
    @objc static var contentTitleColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    /// Notes text foreground color
    @objc static var contentTextColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    /// Notes text background color
    @objc static var contentBackgroundColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    // MARK: DETAILS

    /// Notes details title text color
    @objc static var detailsTitleColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    /// Notes details background color
    @objc static var detailsBackgroundColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    // MARK: SYSTEM OVERRIDE

    override open class var labelColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

    override open class var secondaryLabelColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }

}
