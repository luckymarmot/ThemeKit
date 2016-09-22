//
//  ThemeColor.swift
//  CoreColor
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

private var _cachedColors: NSCache<NSString, NSColor>!
private var _cachedThemeColors: NSCache<NSString, NSColor>!

/**
 `ThemeColor` is a `NSColor` subclass that dynamically changes its colors whenever
 a new theme is make current.
 
 The recommended way of adding your own dynamic colors is as follows:
 
 1. Add a `ThemeColor` class extension (or `TKThemeColor` category on Objective-C)
 to add class methods for your colors. E.g.:
     In Swift:
     ```
     extension ThemeColor {
     
       static var brandColor: ThemeColor { 
         return ThemeColor.color(with: #function)
       }
     
     }
     ```
     In Objective-C:
     ```
     @interface TKThemeColor (Demo)
     
     + (TKThemeColor*)brandColor;
     
     @end
     
     @implementation TKThemeColor (Demo)
     
     + (TKThemeColor*)brandColor {
       return [TKThemeColor colorWithSelector:_cmd];
     }
     
     @end
     ```
 
 2. Add Class Extensions on `LightTheme` and `DarkTheme` (`TKLightTheme` and 
 `TKDarkTheme` on Objective-C) to provide instance methods for each theme color 
 class method defined on (1). E.g.:
    In Swift:
     ```
     extension LightTheme {
     
       var brandColor: NSColor {
         return NSColor.orange
       }
 
     }
 
    extension DarkTheme {
     
      var brandColor: NSColor {
        return NSColor.white
      }
 
    }
     ```
     In Objective-C:
     ```
     @interface TKLightTheme (Demo) @end
     
     @implementation TKLightTheme (Demo)

        - (NSColor*)brandColor
        {
            return [NSColor orangeColor];
        }
 
     @end
 
     @interface TKDarkTheme (Demo) @end
     
     @implementation TKDarkTheme (Demo)

        - (NSColor*)brandColor
        {
            return [NSColor whiteColor];
        }
 
     @end
     ```
 
 3. If using user theme files (`.theme` user theme files), also specify properties
 for each theme color class method defined on (1). E.g.:
    ```
    displayName = Sample User Theme
    identifier = com.luckymarmot.ThemeKit.SampleUserTheme
    darkTheme = false
 
    brandColor = rgba(96, 240, 12, 0.5)
    ```
 
 Unimplemented properties/methods on target theme class will default to
 `fallbackForegroundColor` and `fallbackBackgroundColor`, for foreground and
 background colors respectively. These too, can be customized per theme.
 
 Please check `ThemeGradient` for theme-aware gradients.
 */
@objc(TKThemeColor)
public class ThemeColor : NSColor {
    
    /** Color selector for the theme class */
    var themeColorSelector: Selector
    
    /** Resolved color from current theme */
    var resolvedThemeColor: NSColor? {
        if _colorSpace == nil {
            return _resolvedThemeColor
        }
        else {
            return _resolvedThemeColor?.usingColorSpace(_colorSpace!)
        }
    }
    
    
    // MARK:- Public
    
    /** Create a new ThemeColor instance for the specified selector */
    @objc(colorWithSelector:)
    public class func color(with selector: Selector) -> ThemeColor {
        return color(with: selector, colorSpace: nil)
    }
    
    
    // MARK:- Internal
    
    /** Color for a specific theme */
    @objc(colorForTheme:selector:)
    class func color(for theme: Theme, selector: Selector) -> NSColor {
        let cacheKey = "\(theme.identifier)\0\(selector)" as NSString
        var color = _cachedThemeColors.object(forKey: cacheKey)
        
        if color == nil && theme is NSObject {
            let nsTheme = theme as! NSObject
            
            // Theme provides this asset from optional function themeAsset()?
            color = theme.themeAsset?(NSStringFromSelector(selector)) as? NSColor
            
            // Theme provides this asset from an instance method?
            if color == nil && nsTheme.responds(to: selector) {
                color = nsTheme.perform(selector).takeUnretainedValue() as? NSColor
            }
            
            // Otherwise, use fallback colors
            if color == nil {
                let selectorString = NSStringFromSelector(selector)
                if selectorString.contains("Background") {
                    color = theme.fallbackBackgroundColor ?? theme.defaultFallbackBackgroundColor
                }
                else {
                    color = theme.fallbackForegroundColor ?? theme.defaultFallbackForegroundColor
                }
            }
            
            // Cache it
            color = color?.usingColorSpace(.genericRGB)
            _cachedThemeColors.setObject(color!, forKey: cacheKey)
        }
        
        return color!
    }
    
    /** Current theme color, but respecting view appearance */
    @objc(colorForView:selector:)
    class func color(for view: NSView, selector: Selector) -> NSColor? {
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance.init(named: NSAppearanceNameAqua)
        let lightAppearance = NSAppearance.init(named: NSAppearanceNameVibrantLight)
        let darkAppearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
        let windowIsNSVBAccessoryWindow = view.window?.isKind(of: NSClassFromString("NSVBAccessoryWindow")!) ?? false
        
        // using a dark theme but control is on a light surface => use light theme instead
        if ThemeKit.shared.effectiveTheme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance || windowIsNSVBAccessoryWindow) {
            return ThemeColor.color(for: ThemeKit.lightTheme, selector: selector)
        }
        else if ThemeKit.shared.effectiveTheme.isLightTheme && viewAppearance == darkAppearance {
            return ThemeColor.color(for: ThemeKit.darkTheme, selector: selector)
        }
        
        // any other case => current theme color
        return ThemeColor.color(with: selector)
    }
    
    
    // MARK:- Private Implementation
    
    private var _colorSpace: NSColorSpace?
    private var _resolvedThemeColor: NSColor?
    
    open override class func initialize() {
        _cachedColors = NSCache.init()
        _cachedThemeColors = NSCache.init()
        _cachedColors.name = "com.luckymarmot.ThemeColor.cachedColors"
        _cachedThemeColors.name = "com.luckymarmot.ThemeColor.cachedThemeColors"
    }
    
    class func color(with selector: Selector, colorSpace: NSColorSpace?) -> ThemeColor {
        let cacheKey = "\(selector)\0\(colorSpace)\0\(self)" as NSString
        var color = _cachedColors.object(forKey: cacheKey)
        if color == nil {
            color = ThemeColor.init(with: selector, colorSpace: colorSpace)
            _cachedColors.setObject(color!, forKey: cacheKey)
        }
        return color as! ThemeColor
    }
    
    init(with selector: Selector, colorSpace: NSColorSpace!) {
        themeColorSelector = selector
        _colorSpace = colorSpace
        super.init()
        recacheColor()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheColor), name: .didChangeTheme, object: nil)

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience public init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        fatalError("init(colorLiteralRed:green:blue:alpha:) has not been implemented")
    }
    
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    func recacheColor() {
        // If it is a UserTheme we actually want to discard theme cached values
        if ThemeKit.shared.effectiveTheme is UserTheme {
            _cachedThemeColors.removeAllObjects()
        }
        
        // Recache resolved color
        _resolvedThemeColor = ThemeColor.color(for: ThemeKit.shared.effectiveTheme, selector: themeColorSelector)
    }
    
    
    // MARK:- NSColor Overrides
    
    
    override public func setFill() {
        resolvedThemeColor?.setFill()
    }
    
    override public func setStroke() {
        resolvedThemeColor?.setStroke()
    }
    
    override public func set() {
        resolvedThemeColor?.set()
    }
    
    override public func usingColorSpace(_ space: NSColorSpace) -> NSColor? {
        return ThemeColor.color(with: themeColorSelector, colorSpace: space)
    }
    
    override public func usingColorSpaceName(_ colorSpace: String?, device deviceDescription: [String : Any]?) -> NSColor? {
        if colorSpace == self.colorSpaceName {
            return self
        }
        
        let newColorSpace: NSColorSpace
        if colorSpace == NSCalibratedWhiteColorSpace {
            newColorSpace = NSColorSpace.genericGray
        }
        else if colorSpace == NSCalibratedRGBColorSpace {
            newColorSpace = NSColorSpace.genericRGB
        }
        else if colorSpace == NSDeviceWhiteColorSpace {
            newColorSpace = NSColorSpace.deviceGray
        }
        else if colorSpace == NSDeviceRGBColorSpace {
            newColorSpace = NSColorSpace.deviceRGB
        }
        else if colorSpace == NSDeviceCMYKColorSpace {
            newColorSpace = NSColorSpace.deviceCMYK
        }
        else if colorSpace == NSCustomColorSpace {
            newColorSpace = NSColorSpace.genericRGB
        }
        else {
            /* unsupported colorspace conversion */
            return nil
        }
        
        return ThemeColor.color(with: themeColorSelector, colorSpace: newColorSpace)
    }
    
    override public var colorSpaceName: String {
        return (resolvedThemeColor?.colorSpaceName)!
    }
    
    override public var colorSpace: NSColorSpace {
        return (resolvedThemeColor?.colorSpace)!
    }
    
    override public var numberOfComponents: Int {
        return (_resolvedThemeColor?.numberOfComponents)!
    }
    
    override public func getComponents(_ components: UnsafeMutablePointer<CGFloat>) {
        _resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.getComponents(components)
    }
    
    override public var redComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.redComponent)!
    }
    
    override public var greenComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.greenComponent)!
    }
    
    override public var blueComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.blueComponent)!
    }
    
    override public func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        _resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.getRed(red, green: green, blue: blue, alpha: alpha)
    }
    
    override public var cyanComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericCMYK)?.cyanComponent)!
    }
    
    override public var magentaComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericCMYK)?.magentaComponent)!
    }
    
    override public var yellowComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericCMYK)?.yellowComponent)!
    }
    
    override public var blackComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericCMYK)?.blackComponent)!
    }
    
    override public func getCyan(_ cyan: UnsafeMutablePointer<CGFloat>?, magenta: UnsafeMutablePointer<CGFloat>?, yellow: UnsafeMutablePointer<CGFloat>?, black: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        _resolvedThemeColor?.usingColorSpace(NSColorSpace.genericCMYK)?.getCyan(cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
    
    override public var whiteComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericGray)?.whiteComponent)!
    }
    
    override public func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        _resolvedThemeColor?.usingColorSpace(NSColorSpace.genericGray)?.getWhite(white, alpha: alpha)
    }
    
    override public var hueComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.hueComponent)!
    }
    
    override public var saturationComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.saturationComponent)!
    }
    
    override public var brightnessComponent: CGFloat {
        return (_resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.brightnessComponent)!
    }
    
    override public func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        _resolvedThemeColor?.usingColorSpace(NSColorSpace.genericRGB)?.getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    override public func highlight(withLevel val: CGFloat) -> NSColor? {
        return resolvedThemeColor?.highlight(withLevel: val)
    }
    
    override public func shadow(withLevel val: CGFloat) -> NSColor? {
        return resolvedThemeColor?.shadow(withLevel: val)
    }
    
    override public func withAlphaComponent(_ alpha: CGFloat) -> NSColor {
        return (resolvedThemeColor?.withAlphaComponent(alpha))!
    }
    
    override public var description: String {
        return "\(super.description): \(NSStringFromSelector(themeColorSelector))"
    }
}
