//
//  ThemeGradient.swift
//  CoreColor
//
//  Created by Nuno Grilo on 07/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

private var _cachedGradients: NSCache<NSString, NSGradient>!
private var _cachedThemeGradients: NSCache<NSString, NSGradient>!

/**
 `ThemeGradient` is a `NSGradient` subclass that dynamically changes its colors 
 whenever a new theme is make current.
 
 The recommended way of adding your own dynamic colors is as follows:
 
 1. Add a `ThemeGradient` class extension (or `TKThemeGradient` category on 
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
 
 2. Add Class Extensions on `LightTheme` and `DarkTheme` (`TKLightTheme` and
 `TKDarkTheme` on Objective-C) to provide instance methods for each theme gradient
 class method defined on (1). E.g.:
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
 
 3. If using user theme files (`.theme` user theme files), also specify properties
 for each theme gradient class method defined on (1). E.g.:
     ```
     displayName = Sample User Theme
     identifier = com.luckymarmot.ThemeKit.SampleUserTheme
     darkTheme = false
     
     orangeSky = rgb(160, 90, 45, .5)
     brandGradient = linear-gradient($orangeSky, rgb(200, 140, 60))
     ```
 
 Unimplemented properties/methods on target theme class will default to
 `fallbackGradient`. This too, can be customized per theme.
 
 Please check `ThemeColor` for theme-aware colors.
 */
@objc(TKThemeGradient)
public class ThemeGradient : NSGradient {
    
    /** Gradient selector for the theme class */
    var themeGradientSelector: Selector
    
    /** Resolved gradient from current theme */
    var resolvedThemeGradient: NSGradient
    
    
    // MARK:- Public
    
    /** Create a new ThemeGradient instance for the specified selector */
    @objc(gradientWithSelector:)
    public class func gradient(with selector: Selector) -> ThemeGradient {
        let cacheKey = "\(selector)\0\(self)" as NSString
        var gradient = _cachedGradients.object(forKey: cacheKey)
        if gradient == nil {
            gradient = ThemeGradient.init(with: selector)
            _cachedGradients.setObject(gradient!, forKey: cacheKey)
        }
        return gradient as! ThemeGradient
    }
    
    
    // MARK:- Internal
    
    /** Gradient for a specific theme */
    class func gradient(for theme: Theme, selector: Selector) -> NSGradient {
        let cacheKey = "\(theme.identifier)\0\(selector)" as NSString
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
                gradient = theme.fallbackGradient ?? theme.defaultFallbackGradient
            }
            
            // Cache it
            _cachedThemeGradients.setObject(gradient!, forKey: cacheKey)
        }
        
        return gradient!
    }
    
    
    // MARK:- Private Implementation
    
    private var _resolvedThemeGradient: NSGradient?
    
    open override class func initialize() {
        _cachedGradients = NSCache.init()
        _cachedThemeGradients = NSCache.init()
        _cachedGradients.name = "com.luckymarmot.ThemeGradient.cachedGradients"
        _cachedThemeGradients.name = "com.luckymarmot.ThemeGradient.cachedThemeGradients"
    }
    
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
    
    func recacheGradient() {// If it is a UserTheme we actually want to discard theme cached values
        if ThemeKit.shared.effectiveTheme is UserTheme {
            _cachedThemeGradients.removeAllObjects()
        }
        
        // Recache resolved color
        
        resolvedThemeGradient = ThemeGradient.gradient(for: ThemeKit.shared.effectiveTheme, selector: themeGradientSelector)
    }
    
    override public func draw(in rect: NSRect, angle: CGFloat) {
        resolvedThemeGradient.draw(in: rect, angle: angle)
    }
    
    override public func draw(in path: NSBezierPath, angle: CGFloat) {
        resolvedThemeGradient.draw(in: path, angle: angle)
    }
    
    override public func draw(from startingPoint: NSPoint, to endingPoint: NSPoint, options: NSGradientDrawingOptions = []) {
        resolvedThemeGradient.draw(from: startingPoint, to: endingPoint, options: options)
    }
    
    override public func draw(fromCenter startCenter: NSPoint, radius startRadius: CGFloat, toCenter endCenter: NSPoint, radius endRadius: CGFloat, options: NSGradientDrawingOptions = []) {
        resolvedThemeGradient.draw(fromCenter: startCenter, radius: startRadius, toCenter: endCenter, radius: endRadius, options: options)
    }
    
    override public func draw(in rect: NSRect, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient.draw(in: rect, relativeCenterPosition: relativeCenterPosition)
    }
    
    override public func draw(in path: NSBezierPath, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient.draw(in: path, relativeCenterPosition: relativeCenterPosition)
    }
    
    override public var description: String {
        return "\(super.description): \(NSStringFromSelector(themeGradientSelector))"
    }
}
