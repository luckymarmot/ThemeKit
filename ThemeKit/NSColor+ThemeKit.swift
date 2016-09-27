//
//  NSColor+ThemeKit.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 24/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/**
 `NSColor` extensions.
 Jazzy will fail to generate documentation for this extension.
 Check https://github.com/realm/jazzy/pull/508 and https://github.com/realm/jazzy/issues/502
 */
extension NSColor {
    
    /// Initialize
    open override class func initialize() {
        // process once (if swizzle needed)
        guard !processed else { return }
        processed = true
        guard needsSwizzling else { return }
        
        // swizzle NSColor methods
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(set), withSelector: #selector(themeKitSet))
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(setFill), withSelector: #selector(themeKitSetFill))
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(setStroke), withSelector: #selector(themeKitSetStroke))
    }
    
    /// Check if a given color string is overriden in a ThemeColor extension.
    public var isThemeOverriden: Bool {
        let selector = Selector(colorNameComponent)
        
        let themeColorMethod = class_getClassMethod(ThemeColor.classForCoder(), selector)
        let nsColorMethod = class_getClassMethod(NSColor.classForCoder(), selector)
        
        return nsColorMethod != nil && nsColorMethod != themeColorMethod
    }
    
    /// Get all `NSColor` color methods.
    /// Overridable class methods (can be overriden in `ThemeColor` extension).
    public func colorMethodNames() -> [String] {
        let nsColorMethods = NSObject.classMethodNames(for: NSColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }
        return nsColorMethods
    }
    
    // MARK: - Private
    
    /// Processed flag.
    @nonobjc static private var processed = false
    
    /// Check if we need to swizzle NSDynamicSystemColor class.
    private class var needsSwizzling: Bool {
        let themeColorMethods = classMethodNames(for: ThemeColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }
        let nsColorMethods = classMethodNames(for: NSColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }
        
        // checks if NSColor `*Color` class methods are being overriden
        for colorMethod in themeColorMethods {
            if nsColorMethods.contains(colorMethod) {
                // theme color with `colorMethod` selector is overriding a `NSColor` method -> swizzling needed.
                return true
            }
        }
        
        return false
    }
    
    // ThemeKit.set() replacement to use theme-aware color
    public func themeKitSet() {
        // check if the user provides an alternative color
        if isThemeOverriden {
            // call ThemeColor.set() function
            ThemeColor.color(with: colorNameComponent).set()
        }
        else {
            // call original .set() function
            themeKitSet()
        }
    }
    
    // ThemeKit.setFill() replacement to use theme-aware color
    public func themeKitSetFill() {
        // check if the user provides an alternative color
        if isThemeOverriden {
            // call ThemeColor.setFill() function
            ThemeColor.color(with: colorNameComponent).setFill()
        }
        else {
            // call original .setFill() function
            themeKitSetFill()
        }
    }
    
    // ThemeKit.setStroke() replacement to use theme-aware color
    public func themeKitSetStroke() {
        // check if the user provides an alternative color
        if isThemeOverriden {
            // call ThemeColor.setStroke() function
            ThemeColor.color(with: colorNameComponent).setStroke()
        }
        else {
            // call original .setStroke() function
            themeKitSetStroke()
        }
    }
    
}
