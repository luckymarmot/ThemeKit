//
//  ThemeColor.swift
//  ThemeKit
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
 
 Theme-aware means you don't need to check any conditions when choosing which 
 color to draw or set on a control. E.g.:
 
 ```
 myTextField.textColor = ThemeColor.myContentTextColor
 
 ThemeColor.myCircleFillColor.setFill()
 NSBezierPath(rect: bounds).fill()
 ```
 
 The text color of `myTextField` will automatically change when the user switches
 a theme. Similarly, the drawing code will draw with different color depending on
 the selected theme. Unless some drawing cache is being done, there's no need to 
 refresh the UI after changing the current theme.
 
 You can also define a color to be a pattern image using `NSColor(patternImage:)`.
 
 Defining theme-aware colors
 ---------------------------
 The recommended way of adding your own dynamic colors is as follows:
 
 1. **Add a `ThemeColor` class extension** (or `TKThemeColor` category on Objective-C)
 to add class methods for your colors. E.g.:
 
     In Swift:
 
     ```swift
     extension ThemeColor {
     
       static var brandColor: ThemeColor { 
         return ThemeColor.color(with: #function)
       }
     
     }
     ```
 
     In Objective-C:
 
     ```objc
     @interface TKThemeColor (Demo)
     
     + (TKThemeColor*)brandColor;
     
     @end
     
     @implementation TKThemeColor (Demo)
     
     + (TKThemeColor*)brandColor {
       return [TKThemeColor colorWithSelector:_cmd];
     }
     
     @end
     ```
 
 2. **Add Class Extensions on any `Theme` you want to support** (e.g., `LightTheme`
 and `DarkTheme` - `TKLightTheme` and `TKDarkTheme` on Objective-C) to provide
 instance methods for each theme color class method defined on (1). E.g.:
    
     In Swift:
 
     ```swift
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
 
     ```objc
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
 
 3. If supporting `UserTheme`'s, **define properties on user theme files** (`.theme`)
 for each theme color class method defined on (1). E.g.:
 
     ```swift
     displayName = Sample User Theme
     identifier = com.luckymarmot.ThemeKit.SampleUserTheme
     darkTheme = false
 
     brandColor = rgba(96, 240, 12, 0.5)
     ```
 
 Overriding system colors
 ------------------------
 Besides your own colors added as `ThemeColor` class methods, you can also override 
 `NSColor` class methods so that they return theme-aware colors. The procedure is
 exactly the same, so, for example, if adding a method named `labelColor` to a 
 `ThemeColor` extension, that method will be overriden in `NSColor` and the colors
 from `Theme` subclasses will be used instead. 
 In sum, calling `NSColor.labelColor` will return theme-aware colors.
 
 You can get the full list of available/overridable color methods (class methods)
 calling `NSColor.colorMethodNames()`.
 
 At any time, you can check if a system color is being overriden by current theme
 by checking the `NSColor.isThemeOverriden` property (e.g., `NSColor.labelColor.isThemeOverriden`).
 
 When a theme does not override a system color, the original system color will be
 used instead. E.g., you have overrided `ThemeColor.labelColor`, but currently 
 applied theme does not implement `labelColor` -> original `labelColor` will be
 used.
 
 Fallback colors
 ---------------
 With the exception of system overrided named colors, which defaults to the original
 system provided named color when theme does not specifies it, unimplemented
 properties/methods on target theme class will default to `fallbackForegroundColor`
 and `fallbackBackgroundColor`, for foreground and background colors respectively.
 These too, can be customized per theme.
 
 Please check `ThemeGradient` for theme-aware gradients and `ThemeImage` for theme-aware images.
 */
@objc(TKThemeColor)
open class ThemeColor : NSColor {
    
    // MARK: -
    // MARK: Properties
    
    /// `ThemeColor` color selector used as theme instance method for same selector
    /// or, if inexistent, as argument in the theme instance method `themeAsset(_:)`.
    public var themeColorSelector: Selector = #selector(getter: NSColor.clear)
    
    /// Resolved color from current theme (dynamically changes with the current theme).
    public lazy var resolvedThemeColor: NSColor = NSColor.clear
    
    /// Theme color space (if specified).
    private var themeColorSpace: NSColorSpace?
    
    /// Average color of pattern image from resolved color (nil for non-pattern image colors)
    private var themePatternImageAverageColor: NSColor = NSColor.clear
    
    
    // MARK: -
    // MARK: Creating Colors
    
    /// Create a new ThemeColor instance for the specified selector.
    ///
    /// Returns a color returned by calling `selector` on current theme as an instance method or,
    /// if unavailable, the result of calling `themeAsset(_:)` on the current theme.
    ///
    /// - parameter selector: Selector for color method.
    ///
    /// - returns: A `ThemeColor` instance for the specified selector.
    @objc(colorWithSelector:)
    public class func color(with selector: Selector) -> ThemeColor {
        return color(with: selector, colorSpace: nil)
    }
    
    /// Create a new ThemeColor instance for the specified color name component 
    /// (usually, a string selector).
    ///
    /// Color name component will then be called as a selector on current theme 
    /// as an instance method or, if unavailable, the result of calling 
    /// `themeAsset(_:)` on the current theme.
    ///
    /// - parameter selector: Selector for color method.
    ///
    /// - returns: A `ThemeColor` instance for the specified selector.
    @objc(colorWithColorNameComponent:)
    internal class func color(with colorNameComponent: String) -> ThemeColor {
        return color(with: Selector(colorNameComponent), colorSpace: nil)
    }
    
    /// Color for a specific theme.
    ///
    /// - parameter theme:    A `Theme` instance.
    /// - parameter selector: A color selector.
    ///
    /// - returns: Resolved color for specified selector on given theme.
    @objc(colorForTheme:selector:)
    public class func color(for theme: Theme, selector: Selector) -> NSColor {
        let cacheKey = "\(theme.identifier.hashValue)\0\(selector.hashValue)" as NSString
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
                    // try with theme provided `fallbackBackgroundColor`
                    color = theme.fallbackBackgroundColor ?? theme.themeAsset?("fallbackBackgroundColor") as? NSColor
                    if color == nil {
                        // otherwise just use default fallback color
                        color = theme.defaultFallbackBackgroundColor
                    }
                }
                else {
                    // try with theme provided `fallbackForegroundColor`
                    color = theme.fallbackForegroundColor ?? theme.themeAsset?("fallbackForegroundColor") as? NSColor
                    if color == nil {
                        // otherwise just use default fallback color
                        color = theme.defaultFallbackForegroundColor
                    }
                }
            }
            
            // Store as Calibrated RGB if not a pattern image
            if color?.colorSpaceName != NSPatternColorSpace {
                color = color?.usingColorSpace(.genericRGB)
            }
            
            // Cache it
            _cachedThemeColors.setObject(color!, forKey: cacheKey)
        }
        
        return color!
    }
    
    /// Current theme color, but respecting view appearance and any window
    /// specific theme (if set).
    ///
    /// If a `NSWindow.windowTheme` was set, it will be used instead.
    /// Some views may be using a different appearance than the theme appearance.
    /// In thoses cases, color won't be resolved using current theme, but from 
    /// either `lightTheme` or `darkTheme`, depending of whether view appearance
    /// is light or dark, respectively.
    ///
    /// - parameter view:     A `NSView` instance.
    /// - parameter selector: A color selector.
    ///
    /// - returns: Resolved color for specified selector on given view.
    @objc(colorForView:selector:)
    public class func color(for view: NSView, selector: Selector) -> NSColor {
        let theme = view.window?.windowEffectiveTheme ?? ThemeKit.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance.init(named: NSAppearanceNameAqua)
        let lightAppearance = NSAppearance.init(named: NSAppearanceNameVibrantLight)
        let darkAppearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
        let windowIsNSVBAccessoryWindow = view.window?.isKind(of: NSClassFromString("NSVBAccessoryWindow")!) ?? false
        
        // using a dark theme but control is on a light surface => use light theme instead
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance || windowIsNSVBAccessoryWindow) {
            return ThemeColor.color(for: ThemeKit.lightTheme, selector: selector)
        }
        else if theme.isLightTheme && viewAppearance == darkAppearance {
            return ThemeColor.color(for: ThemeKit.darkTheme, selector: selector)
        }
        
        // if a custom window theme was set, use the appropriate asset
        if view.window?.windowTheme != nil {
            return ThemeColor.color(for: theme, selector: selector)
        }
        
        // otherwise, return current theme color
        return ThemeColor.color(with: selector)
    }
    
    /// Static initialization.
    open override class func initialize() {
        _cachedColors = NSCache.init()
        _cachedThemeColors = NSCache.init()
        _cachedColors.name = "com.luckymarmot.ThemeColor.cachedColors"
        _cachedThemeColors.name = "com.luckymarmot.ThemeColor.cachedThemeColors"
    }
    
    /// Returns a new `ThemeColor` for the fiven selector in the specified colorspace.
    ///
    /// - parameter selector:   A color selector.
    /// - parameter colorSpace: An optional `NSColorSpace`.
    ///
    /// - returns: A `ThemeColor` instance in the specified colorspace.
    class func color(with selector: Selector, colorSpace: NSColorSpace?) -> ThemeColor {
        let cacheKey = "\(selector.hashValue)\0\(colorSpace == nil ? 0 : colorSpace!.hashValue)\0\(self.hash())" as NSString
        var color = _cachedColors.object(forKey: cacheKey)
        if color == nil {
            color = ThemeColor.init(with: selector, colorSpace: colorSpace)
            _cachedColors.setObject(color!, forKey: cacheKey)
        }
        return color as! ThemeColor
    }
    
    /// Returns a new `ThemeColor` for the fiven selector in the specified colorpsace.
    ///
    /// - parameter selector:   A color selector.
    /// - parameter colorSpace: An optional `NSColorSpace`.
    ///
    /// - returns: A `ThemeColor` instance in the specified colorspace.
    init(with selector: Selector, colorSpace: NSColorSpace!) {
        themeColorSelector = selector
        themeColorSpace = colorSpace
        super.init()
        recacheColor()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheColor), name: .didChangeTheme, object: nil)

    }
    
    required convenience public init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        fatalError("init(colorLiteralRed:green:blue:alpha:) has not been implemented")
    }
    
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if aDecoder.allowsKeyedCoding {
            themeColorSelector = NSSelectorFromString((aDecoder.decodeObject(forKey: "themeColorSelector") as? String)!)
        }
        else {
            themeColorSelector = NSSelectorFromString((aDecoder.decodeObject() as? String)!)
        }
        
        recacheColor()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheColor), name: .didChangeTheme, object: nil)
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        if aCoder.allowsKeyedCoding {
            aCoder.encode(NSStringFromSelector(themeColorSelector), forKey: "themeColorSelector")
        }
        else {
            aCoder.encode(NSStringFromSelector(themeColorSelector))
        }
    }
    
    /// Forces dynamic color resolution into `resolvedThemeColor` and cache it.
    /// You should not need to manually call this function.
    open func recacheColor() {
        // If it is a UserTheme we actually want to discard theme cached values
        if ThemeKit.shared.effectiveTheme is UserTheme {
            _cachedThemeColors.removeAllObjects()
        }
        
        // Recache resolved color
        let newColor = ThemeColor.color(for: ThemeKit.shared.effectiveTheme, selector: themeColorSelector)
        if themeColorSpace == nil {
            resolvedThemeColor = newColor
        }
        else {
            let convertedColor = newColor.usingColorSpace(themeColorSpace!)
            resolvedThemeColor = convertedColor ?? newColor
        }
        
        // Recache average color of pattern image, if appropriate
        themePatternImageAverageColor = resolvedThemeColor.colorSpaceName == NSPatternColorSpace ? resolvedThemeColor.patternImage.averageColor() : NSColor.clear
    }
    
    
    // MARK:- NSColor Overrides
    
    override open func setFill() {
        resolvedThemeColor.setFill()
    }
    
    override open func setStroke() {
        resolvedThemeColor.setStroke()
    }
    
    override open func set() {
        resolvedThemeColor.set()
    }
    
    override open func usingColorSpace(_ space: NSColorSpace) -> NSColor? {
        return ThemeColor.color(with: themeColorSelector, colorSpace: space)
    }
    
    override open func usingColorSpaceName(_ colorSpace: String?, device deviceDescription: [String : Any]?) -> NSColor? {
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
    
    override open var colorSpaceName: String {
        return resolvedThemeColor.colorSpaceName
    }
    
    override open var colorSpace: NSColorSpace {
        return resolvedThemeColor.colorSpace
    }
    
    override open var numberOfComponents: Int {
        return resolvedThemeColor.numberOfComponents
    }
    
    override open func getComponents(_ components: UnsafeMutablePointer<CGFloat>) {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(NSColorSpace.genericRGB)?.getComponents(components)
    }
    
    override open var redComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.redComponent)!
    }
    
    override open var greenComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.greenComponent)!
    }
    
    override open var blueComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.blueComponent)!
    }
    
    override open func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(NSColorSpace.genericRGB)?.getRed(red, green: green, blue: blue, alpha: alpha)
    }
    
    override open var cyanComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericCMYK)?.cyanComponent)!
    }
    
    override open var magentaComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericCMYK)?.magentaComponent)!
    }
    
    override open var yellowComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericCMYK)?.yellowComponent)!
    }
    
    override open var blackComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericCMYK)?.blackComponent)!
    }
    
    override open func getCyan(_ cyan: UnsafeMutablePointer<CGFloat>?, magenta: UnsafeMutablePointer<CGFloat>?, yellow: UnsafeMutablePointer<CGFloat>?, black: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(NSColorSpace.genericCMYK)?.getCyan(cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
    
    override open var whiteComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericGray)?.whiteComponent)!
    }
    
    override open func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(NSColorSpace.genericGray)?.getWhite(white, alpha: alpha)
    }
    
    override open var hueComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.hueComponent)!
    }
    
    override open var saturationComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.saturationComponent)!
    }
    
    override open var brightnessComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return (color.usingColorSpace(NSColorSpace.genericRGB)?.brightnessComponent)!
    }
    
    override open func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(NSColorSpace.genericRGB)?.getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    override open func highlight(withLevel val: CGFloat) -> NSColor? {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return color.highlight(withLevel: val)
    }
    
    override open func shadow(withLevel val: CGFloat) -> NSColor? {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return color.shadow(withLevel: val)
    }
    
    override open func withAlphaComponent(_ alpha: CGFloat) -> NSColor {
        let color = resolvedThemeColor.colorSpaceName != NSPatternColorSpace ? resolvedThemeColor : themePatternImageAverageColor
        return color.withAlphaComponent(alpha)
    }
    
    override open var description: String {
        return "\(super.description): \(NSStringFromSelector(themeColorSelector))"
    }
}
