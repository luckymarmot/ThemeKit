//
//  ThemeGradient.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 07/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

private var _cachedGradients: NSCache<NSNumber, ThemeGradient>!
private var _cachedThemeGradients: NSCache<NSNumber, NSGradient>!

/**
 `ThemeGradient` is a `NSGradient` subclass that dynamically changes its colors 
 whenever a new theme is make current.
 
 Theme-aware means you don't need to check any conditions when choosing which
 gradient to draw. E.g.:
 
 ```
 ThemeGradient.rainbowGradient.draw(in: bounds, angle: 0)
 ```
 
 The drawing code will draw with different gradient depending on the selected 
 theme. Unless some drawing cache is being done, there's no need to refresh the
 UI after changing the current theme.
 
 Defining theme-aware gradients
 ------------------------------
 
 The recommended way of adding your own dynamic gradients is as follows:
 
 1. **Add a `ThemeGradient` class extension** (or `TKThemeGradient` category on
 Objective-C) to add class methods for your gradients. E.g.:
 
     In Swift:
 
     ```
     extension ThemeGradient {
     
         static var brandGradient: ThemeGradient {
            return ThemeGradient.gradient(with: #function)
         }
     
     }
     ```
 
     In Objective-C:
 
     ```
     @interface TKThemeGradient (Demo)
     
     + (TKThemeGradient*)brandGradient;
     
     @end
     
     @implementation TKThemeGradient (Demo)
     
     + (TKThemeGradient*)brandGradient {
        return [TKThemeGradient gradientWithSelector:_cmd];
     }
     
     @end
     ```
 
 2. **Add Class Extensions on any `Theme` you want to support** (e.g., `LightTheme`
 and `DarkTheme` - `TKLightTheme` and `TKDarkTheme` on Objective-C) to provide
 instance methods for each theme gradient class method defined on (1). E.g.:
 
     In Swift:
 
     ```
     extension LightTheme {
     
         var brandGradient: NSGradient {
            return NSGradient(starting: NSColor.white, ending: NSColor.black)
         }
         
         }
         
         extension DarkTheme {
         
         var brandGradient: NSGradient {
            return NSGradient(starting: NSColor.black, ending: NSColor.white)
         }
     
     }
     ```
 
     In Objective-C:
 
     ```
     @interface TKLightTheme (Demo) @end
     
     @implementation TKLightTheme (Demo)
     
     - (NSGradient*)brandGradient
     {
        return [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
     }
     
     @end
     
     @interface TKDarkTheme (Demo) @end
     
     @implementation TKDarkTheme (Demo)
     
     - (NSGradient*)brandGradient
     {
        return [[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]];
     }
     
     @end
     ```
 
 3.  If supporting `UserTheme`'s, **define properties on user theme files** (`.theme`)
 for each theme gradient class method defined on (1). E.g.:
 
     ```
     displayName = Sample User Theme
     identifier = com.luckymarmot.ThemeKit.SampleUserTheme
     darkTheme = false
     
     orangeSky = rgb(160, 90, 45, .5)
     brandGradient = linear-gradient($orangeSky, rgb(200, 140, 60))
     ```
 
 Fallback colors
 ---------------
 Unimplemented properties/methods on target theme class will default to
 `fallbackGradient`. This too, can be customized per theme.
 
 Please check `ThemeColor` for theme-aware colors and `ThemeImage` for theme-aware images.
 */
@objc(TKThemeGradient)
open class ThemeGradient : NSGradient {
    
    // MARK: -
    // MARK: Properties
    
    /// `ThemeGradient` gradient selector used as theme instance method for same
    /// selector or, if inexistent, as argument in the theme instance method `themeAsset(_:)`.
    public var themeGradientSelector: Selector
    
    /// Resolved gradient from current theme (dynamically changes with the current theme).
    public var resolvedThemeGradient: NSGradient
    
    
    // MARK: -
    // MARK: Creating Gradients
    
    /// Create a new ThemeGradient instance for the specified selector.
    ///
    /// - parameter selector: Selector for color method.
    ///
    /// - returns: A `ThemeGradient` instance for the specified selector.
    @objc(gradientWithSelector:)
    public class func gradient(with selector: Selector) -> ThemeGradient {
        let cacheKey = CacheKey(selector: selector)
        var gradient = _cachedGradients.object(forKey: cacheKey)
        if gradient == nil {
            gradient = ThemeGradient.init(with: selector)
            _cachedGradients.setObject(gradient!, forKey: cacheKey)
        }
        return gradient!
    }
    
    /// Gradient for a specific theme.
    ///
    /// - parameter theme:    A `Theme` instance.
    /// - parameter selector: A gradient selector.
    ///
    /// - returns: Resolved gradient for specified selector on given theme.
    @objc(gradientForTheme:selector:)
    public class func gradient(for theme: Theme, selector: Selector) -> NSGradient {
        let cacheKey = CacheKey(selector: selector, theme: theme)
        var gradient = _cachedThemeGradients.object(forKey: cacheKey)
        
        if gradient == nil && theme is NSObject {
            // Theme provides this asset from optional function themeAsset()?
            gradient = theme.themeAsset?(NSStringFromSelector(selector)) as? NSGradient
            
            // Theme provides this asset from an instance method?
            let nsTheme = theme as! NSObject
            if gradient == nil && nsTheme.responds(to: selector) {
                gradient = nsTheme.perform(selector).takeUnretainedValue() as? NSGradient
            }
            
            // Otherwise, use fallback gradient
            if gradient == nil {
                // try with theme provided `fallbackGradient`
                gradient = theme.fallbackGradient ?? theme.themeAsset?("fallbackGradient") as? NSGradient
                if gradient == nil {
                    // otherwise just use default fallback gradient
                    gradient = theme.defaultFallbackGradient
                }
            }
            
            // Cache it
            _cachedThemeGradients.setObject(gradient!, forKey: cacheKey)
        }
        
        return gradient!
    }
    
    /// Current theme gradient, but respecting view appearance and any window
    /// specific theme (if set).
    ///
    /// If a `NSWindow.windowTheme` was set, it will be used instead.
    /// Some views may be using a different appearance than the theme appearance.
    /// In thoses cases, gradient won't be resolved using current theme, but from
    /// either `lightTheme` or `darkTheme`, depending of whether view appearance
    /// is light or dark, respectively.
    ///
    /// - parameter view:     A `NSView` instance.
    /// - parameter selector: A gradient selector.
    ///
    /// - returns: Resolved gradient for specified selector on given view.
    @objc(gradientForView:selector:)
    public class func gradient(for view: NSView, selector: Selector) -> NSGradient {
        // if a custom window theme was set, use the appropriate asset
        if view.window?.windowTheme != nil {
            return ThemeGradient.gradient(for: (view.window?.windowTheme)!, selector: selector)
        }
        
        let theme = ThemeKit.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance.init(named: NSAppearanceNameAqua)
        let lightAppearance = NSAppearance.init(named: NSAppearanceNameVibrantLight)
        let darkAppearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
        let windowIsNSVBAccessoryWindow = view.window?.isKind(of: NSClassFromString("NSVBAccessoryWindow")!) ?? false
        
        // using a dark theme but control is on a light surface => use light theme instead
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance || windowIsNSVBAccessoryWindow) {
            return ThemeGradient.gradient(for: ThemeKit.lightTheme, selector: selector)
        }
        else if theme.isLightTheme && viewAppearance == darkAppearance {
            return ThemeGradient.gradient(for: ThemeKit.darkTheme, selector: selector)
        }
        
        // otherwise, return current theme gradient
        return ThemeGradient.gradient(with: selector)
    }
    
    open override class func initialize() {
        _cachedGradients = NSCache.init()
        _cachedThemeGradients = NSCache.init()
        _cachedGradients.name = "com.luckymarmot.ThemeGradient.cachedGradients"
        _cachedThemeGradients.name = "com.luckymarmot.ThemeGradient.cachedThemeGradients"
    }
    
    /// Returns a new `ThemeGradient` for the given selector.
    ///
    /// - parameter selector:   A gradient selector.
    ///
    /// - returns: A `ThemeGradient` instance.
    init(with selector: Selector) {
        themeGradientSelector = selector
        let defaultColor = ThemeKit.shared.effectiveTheme.defaultFallbackBackgroundColor
        resolvedThemeGradient = NSGradient.init(starting: defaultColor, ending: defaultColor)!
        
        super.init(colors: [defaultColor, defaultColor], atLocations: [0.0, 1.0], colorSpace: NSColorSpace.genericRGB)!
        
        recacheGradient()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheGradient), name: .didChangeTheme, object: nil)
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Forces dynamic gradient resolution into `resolvedThemeGradient` and cache it.
    /// You should not need to manually call this function.
    open func recacheGradient() {
        // If it is a UserTheme we actually want to discard theme cached values
        if ThemeKit.shared.effectiveTheme is UserTheme {
            ThemeGradient.emptyCache()
        }
        
        // Recache resolved color
        resolvedThemeGradient = ThemeGradient.gradient(for: ThemeKit.shared.effectiveTheme, selector: themeGradientSelector)
    }
    
    /// Clear all caches.
    /// You should not need to manually call this function.
    static open func emptyCache() {
        _cachedGradients.removeAllObjects()
        _cachedThemeGradients.removeAllObjects()
    }
    
    override open func draw(in rect: NSRect, angle: CGFloat) {
        resolvedThemeGradient.draw(in: rect, angle: angle)
    }
    
    override open func draw(in path: NSBezierPath, angle: CGFloat) {
        resolvedThemeGradient.draw(in: path, angle: angle)
    }
    
    override open func draw(from startingPoint: NSPoint, to endingPoint: NSPoint, options: NSGradientDrawingOptions = []) {
        resolvedThemeGradient.draw(from: startingPoint, to: endingPoint, options: options)
    }
    
    override open func draw(fromCenter startCenter: NSPoint, radius startRadius: CGFloat, toCenter endCenter: NSPoint, radius endRadius: CGFloat, options: NSGradientDrawingOptions = []) {
        resolvedThemeGradient.draw(fromCenter: startCenter, radius: startRadius, toCenter: endCenter, radius: endRadius, options: options)
    }
    
    override open func draw(in rect: NSRect, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient.draw(in: rect, relativeCenterPosition: relativeCenterPosition)
    }
    
    override open func draw(in path: NSBezierPath, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient.draw(in: path, relativeCenterPosition: relativeCenterPosition)
    }
    
    override open var colorSpace: NSColorSpace {
        return resolvedThemeGradient.colorSpace
    }
    
    override open var numberOfColorStops: Int {
        return resolvedThemeGradient.numberOfColorStops
    }
    
    override open func getColor(_ color: AutoreleasingUnsafeMutablePointer<NSColor>?, location: UnsafeMutablePointer<CGFloat>?, at index: Int) {
        resolvedThemeGradient.getColor(color, location: location, at: index)
    }
    
    override open func interpolatedColor(atLocation location: CGFloat) -> NSColor {
        return resolvedThemeGradient.interpolatedColor(atLocation: location)
    }
    
    override open var description: String {
        return "\(super.description): \(NSStringFromSelector(themeGradientSelector))"
    }
}
