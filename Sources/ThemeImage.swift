//
//  ThemeImage.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 03/10/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

private var _cachedImages: NSCache<NSString, ThemeImage>!
private var _cachedThemeImages: NSCache<NSString, NSImage>!


/**
 `ThemeImage` is a `NSImage` subclass that dynamically changes its colors
 whenever a new theme is make current.
 
 Theme-aware means you don't need to check any conditions when choosing which
 image to draw. E.g.:
 
 ```
 ThemeImage.logoImage.draw(in: bounds)
 ```
 
 The drawing code will draw with different image depending on the selected
 theme. Unless some drawing cache is being done, there's no need to refresh the
 UI after changing the current theme.
 
 Defining theme-aware images
 ---------------------------
 
 The recommended way of adding your own dynamic images is as follows:
 
 1. **Add a `ThemeImage` class extension** (or `TKThemeImage` category on
 Objective-C) to add class methods for your images. E.g.:
 
     In Swift:
     
     ```
     extension ThemeImage {
     
         static var logoImage: ThemeImage {
             return ThemeImage.image(with: #function)
         }
     
     }
     ```
     
     In Objective-C:
     
     ```
     @interface TKThemeImage (Demo)
     
     + (TKThemeImage*)logoImage;
     
     @end
     
     @implementation TKThemeImage (Demo)
     
     + (TKThemeImage*)logoImage {
         return [TKThemeImage imageWithSelector:_cmd];
     }
     
     @end
     ```
 
 2. **Add Class Extensions on any `Theme` you want to support** (e.g., `LightTheme`
 and `DarkTheme` - `TKLightTheme` and `TKDarkTheme` on Objective-C) to provide 
 instance methods for each theme image class method defined on (1). E.g.:
 
     In Swift:
     
     ```
     extension LightTheme {
     
         var logoImage: NSImage {
             return NSImage(named: "MyLightLogo")!
         }
     
     }
     
     extension DarkTheme {
     
         var logoImage: NSImage {
             return NSImage(contentsOfFile: "somewhere/MyDarkLogo.png")!
         }
     
     }
     ```
     
     In Objective-C:
     
     ```
     @interface TKLightTheme (Demo) @end
     
     @implementation TKLightTheme (Demo)
     
     - (NSImage*)logoImage
     {
         return [NSImage imageNamed:@"MyLightLogo"];
     }
     
     @end
     
     @interface TKDarkTheme (Demo) @end
     
     @implementation TKDarkTheme (Demo)
     
     - (NSImage*)logoImage
     {
         return [NSImage alloc] initWithContentsOfFile:@"somewhere/MyDarkLogo.png"];
     }
     
     @end
     ```
 
 3.  If supporting `UserTheme`'s, **define properties on user theme files** (`.theme`)
 for each theme image class method defined on (1). E.g.:
 
     ```
     displayName = Sample User Theme
     identifier = com.luckymarmot.ThemeKit.SampleUserTheme
     darkTheme = false
     
     logoImage = image(named:MyLogo)
     //logoImage = image(file:../some/path/MyLogo.png)
     ```
 
 Fallback images
 ---------------
 Unimplemented properties/methods on target theme class will default to
 `fallbackImage`. This too, can be customized per theme.
 
 Please check `ThemeColor` for theme-aware colors and `ThemeGradient` for theme-aware gradients.
 */
@objc(TKThemeImage)
open class ThemeImage : NSImage {
    
    // MARK: -
    // MARK: Properties
    
    /// `ThemeImage` image selector used as theme instance method for same
    /// selector or, if inexistent, as argument in the theme instance method `themeAsset(_:)`.
    public var themeImageSelector: Selector?
    
    /// Resolved Image from current theme (dynamically changes with the current theme).
    public var resolvedThemeImage: NSImage = NSImage(size: NSZeroSize)
    
    
    // MARK: -
    // MARK: Creating Images

    
    /// Create a new ThemeImage instance for the specified selector.
    ///
    /// Returns an image returned by calling `selector` on current theme as an instance method or,
    /// if unavailable, the result of calling `themeAsset(_:)` on the current theme.
    ///
    /// - parameter selector: Selector for image method.
    ///
    /// - returns: A `ThemeImage` instance for the specified selector.
    @objc(imageWithSelector:)
    public class func image(with selector: Selector) -> ThemeImage {
        let cacheKey = "\(selector.hashValue)\0\(self.hash())" as NSString
        var image = _cachedImages.object(forKey: cacheKey)
        if image == nil {
            image = ThemeImage.init(with: selector)
            _cachedImages.setObject(image!, forKey: cacheKey)
        }
        return image!
    }
    
    /// Image for a specific theme.
    ///
    /// - parameter theme:    A `Theme` instance.
    /// - parameter selector: An image selector.
    ///
    /// - returns: Resolved image for specified selector on given theme.
    @objc(imageForTheme:selector:)
    public class func image(for theme: Theme, selector: Selector) -> NSImage {
        let cacheKey = "\(theme.identifier.hashValue)\0\(selector.hashValue)" as NSString
        var image = _cachedThemeImages.object(forKey: cacheKey)
        
        if image == nil && theme is NSObject {
            // Theme provides this asset from optional function themeAsset()?
            image = theme.themeAsset?(NSStringFromSelector(selector)) as? NSImage
            
            // Theme provides this asset from an instance method?
            let nsTheme = theme as! NSObject
            if image == nil && nsTheme.responds(to: selector) {
                image = nsTheme.perform(selector).takeUnretainedValue() as? NSImage
            }
            
            // Otherwise, use fallback image
            if image == nil {
                // try with theme provided `fallbackImage`
                image = theme.fallbackImage ?? theme.themeAsset?("fallbackImage") as? NSImage
                if image == nil {
                    // otherwise just use default fallback image
                    image = theme.defaultFallbackImage
                }
            }
            
            // Cache it
            _cachedThemeImages.setObject(image!, forKey: cacheKey)
        }
        
        return image!
    }
    
    /// Current theme image, but respecting view appearance and any window 
    /// specific theme (if set).
    ///
    /// If a `NSWindow.windowTheme` was set, it will be used instead.
    /// Some views may be using a different appearance than the theme appearance.
    /// In thoses cases, image won't be resolved using current theme, but from
    /// either `lightTheme` or `darkTheme`, depending of whether view appearance
    /// is light or dark, respectively.
    ///
    /// - parameter view:     A `NSView` instance.
    /// - parameter selector: An image selector.
    ///
    /// - returns: Resolved image for specified selector on given view.
    @objc(imageForView:selector:)
    public class func image(for view: NSView, selector: Selector) -> NSImage {
        let theme = view.window?.windowEffectiveTheme ?? ThemeKit.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance.init(named: NSAppearanceNameAqua)
        let lightAppearance = NSAppearance.init(named: NSAppearanceNameVibrantLight)
        let darkAppearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
        let windowIsNSVBAccessoryWindow = view.window?.isKind(of: NSClassFromString("NSVBAccessoryWindow")!) ?? false
        
        // using a dark theme but control is on a light surface => use light theme instead
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance || windowIsNSVBAccessoryWindow) {
            return ThemeImage.image(for: ThemeKit.lightTheme, selector: selector)
        }
        else if theme.isLightTheme && viewAppearance == darkAppearance {
            return ThemeImage.image(for: ThemeKit.darkTheme, selector: selector)
        }
        
        // if a custom window theme was set, use the appropriate asset
        if view.window?.windowTheme != nil {
            return ThemeImage.image(for: theme, selector: selector)
        }
        
        // otherwise, return current theme image
        return ThemeImage.image(with: selector)
    }
    
    open override class func initialize() {
        _cachedImages = NSCache.init()
        _cachedThemeImages = NSCache.init()
        _cachedImages.name = "com.luckymarmot.ThemeImage.cachedImages"
        _cachedThemeImages.name = "com.luckymarmot.ThemeImage.cachedThemeImages"
    }
    
    /// Returns a new `ThemeImage` for the given selector.
    ///
    /// - parameter selector: A image selector.
    ///
    /// - returns: A `ThemeImage` instance.
    init(with selector: Selector) {
        themeImageSelector = selector
        resolvedThemeImage = NSImage(size: NSZeroSize)
        
        super.init(size: NSZeroSize)
        
        recacheImage()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheImage), name: .didChangeTheme, object: nil)
    }
    
    required convenience public init(imageLiteralResourceName name: String) {
        fatalError("init(imageLiteralResourceName:) has not been implemented")
    }
    
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if aDecoder.allowsKeyedCoding {
            themeImageSelector = NSSelectorFromString((aDecoder.decodeObject(forKey: "themeImageSelector") as? String)!)
        }
        else {
            themeImageSelector = NSSelectorFromString((aDecoder.decodeObject() as? String)!)
        }
        
        recacheImage()
        NotificationCenter.default.addObserver(self, selector: #selector(recacheImage), name: .didChangeTheme, object: nil)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        if aCoder.allowsKeyedCoding {
            aCoder.encode(NSStringFromSelector(themeImageSelector!), forKey: "themeImageSelector")
        }
        else {
            aCoder.encode(NSStringFromSelector(themeImageSelector!))
        }
    }
    
    /// Forces dynamic color resolution into `resolvedThemeImage` and cache it.
    /// You should not need to manually call this function.
    open func recacheImage() {
        // If it is a UserTheme we actually want to discard theme cached values
        if ThemeKit.shared.effectiveTheme is UserTheme {
            _cachedThemeImages.removeAllObjects()
        }
        
        // Recache resolved image
        resolvedThemeImage = ThemeImage.image(for: ThemeKit.shared.effectiveTheme, selector: themeImageSelector!)
    }
    
    
    override open var size: NSSize {
        get {
            return resolvedThemeImage.size
        }
        set {
            resolvedThemeImage.size = newValue
        }
    }
    
    override open func setName(_ string: String?) -> Bool {
        return resolvedThemeImage.setName(string)
    }
    
    override open func name() -> String? {
        return resolvedThemeImage.name()
    }
    
    override open var backgroundColor: NSColor {
        get {
            return resolvedThemeImage.backgroundColor
        }
        set {
            resolvedThemeImage.backgroundColor = newValue
        }
    }
    
    override open var usesEPSOnResolutionMismatch: Bool {
        get {
            return resolvedThemeImage.usesEPSOnResolutionMismatch
        }
        set {
            resolvedThemeImage.usesEPSOnResolutionMismatch = newValue
        }
    }
    
    override open var prefersColorMatch: Bool {
        get {
            return resolvedThemeImage.prefersColorMatch
        }
        set {
            resolvedThemeImage.prefersColorMatch = newValue
        }
    }
    
    override open var matchesOnMultipleResolution: Bool {
        get {
            return resolvedThemeImage.matchesOnMultipleResolution
        }
        set {
            resolvedThemeImage.matchesOnMultipleResolution = newValue
        }
    }
    
    override open var matchesOnlyOnBestFittingAxis: Bool {
        get {
            return resolvedThemeImage.matchesOnlyOnBestFittingAxis
        }
        set {
            resolvedThemeImage.matchesOnlyOnBestFittingAxis = newValue
        }
    }
    
    override open func draw(at point: NSPoint, from fromRect: NSRect, operation op: NSCompositingOperation, fraction delta: CGFloat) {
        resolvedThemeImage.draw(at: point, from: fromRect, operation: op, fraction: delta)
    }
    
    override open func draw(in rect: NSRect, from fromRect: NSRect, operation op: NSCompositingOperation, fraction delta: CGFloat) {
        resolvedThemeImage.draw(in: rect, from: fromRect, operation: op, fraction: delta)
    }
    
    override open func draw(in dstSpacePortionRect: NSRect, from srcSpacePortionRect: NSRect, operation op: NSCompositingOperation, fraction requestedAlpha: CGFloat, respectFlipped respectContextIsFlipped: Bool, hints: [String : Any]?) {
        resolvedThemeImage.draw(in: dstSpacePortionRect, from: srcSpacePortionRect, operation: op, fraction: requestedAlpha, respectFlipped: respectContextIsFlipped, hints: hints)
    }
    
    override open func drawRepresentation(_ imageRep: NSImageRep, in rect: NSRect) -> Bool {
        return resolvedThemeImage.drawRepresentation(imageRep, in: rect)
    }
    
    override open func draw(in rect: NSRect) {
        resolvedThemeImage.draw(in: rect)
    }
    
    override open func recache() {
        resolvedThemeImage.recache()
    }
    
    override open var tiffRepresentation: Data? {
        return resolvedThemeImage.tiffRepresentation
    }
    
    override open func tiffRepresentation(using comp: NSTIFFCompression, factor: Float) -> Data? {
        return resolvedThemeImage.tiffRepresentation(using: comp, factor: factor)
    }
    
    override open var representations: [NSImageRep] {
        return resolvedThemeImage.representations
    }
    
    override open func addRepresentations(_ imageReps: [NSImageRep]) {
        resolvedThemeImage.addRepresentations(imageReps)
    }
    
    override open func addRepresentation(_ imageRep: NSImageRep) {
        resolvedThemeImage.addRepresentation(imageRep)
    }
    
    override open func removeRepresentation(_ imageRep: NSImageRep) {
        resolvedThemeImage.removeRepresentation(imageRep)
    }
    
    override open var isValid: Bool {
        return resolvedThemeImage.isValid
    }
    
    override open func lockFocus() {
        resolvedThemeImage.lockFocus()
    }
    
    override open func lockFocusFlipped(_ flipped: Bool) {
        resolvedThemeImage.lockFocusFlipped(flipped)
    }
    
    override open func unlockFocus() {
        resolvedThemeImage.unlockFocus()
    }
    
    override open var delegate: NSImageDelegate? {
        get {
            return resolvedThemeImage.delegate
        }
        set {
            resolvedThemeImage.delegate = newValue
        }
    }
    
    override open func cancelIncrementalLoad() {
        resolvedThemeImage.cancelIncrementalLoad()
    }
    
    override open var cacheMode: NSImageCacheMode {
        get {
            return resolvedThemeImage.cacheMode
        }
        set {
            resolvedThemeImage.cacheMode = newValue
        }
    }
    
    override open var alignmentRect: NSRect {
        get {
            return resolvedThemeImage.alignmentRect
        }
        set {
            resolvedThemeImage.alignmentRect = newValue
        }
    }
    
    override open var isTemplate: Bool {
        get {
            return resolvedThemeImage.isTemplate
        }
        set {
            resolvedThemeImage.isTemplate = newValue
        }
    }
    
    override open var accessibilityDescription: String? {
        get {
            return resolvedThemeImage.accessibilityDescription
        }
        set {
            resolvedThemeImage.accessibilityDescription = newValue
        }
    }
    
    override open func cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?, context referenceContext: NSGraphicsContext?, hints: [String : Any]?) -> CGImage? {
        return resolvedThemeImage.cgImage(forProposedRect: proposedDestRect, context: referenceContext, hints: hints)
    }
    
    override open func bestRepresentation(for rect: NSRect, context referenceContext: NSGraphicsContext?, hints: [String : Any]?) -> NSImageRep? {
        return resolvedThemeImage.bestRepresentation(for: rect, context: referenceContext, hints: hints)
    }
    
    override open func hitTest(_ testRectDestSpace: NSRect, withDestinationRect imageRectDestSpace: NSRect, context: NSGraphicsContext?, hints: [String : Any]?, flipped: Bool) -> Bool {
        return resolvedThemeImage.hitTest(testRectDestSpace, withDestinationRect: imageRectDestSpace, context: context, hints: hints, flipped: flipped)
    }
    
    override open func recommendedLayerContentsScale(_ preferredContentsScale: CGFloat) -> CGFloat {
        return resolvedThemeImage.recommendedLayerContentsScale(preferredContentsScale)
    }
    
    override open func layerContents(forContentsScale layerContentsScale: CGFloat) -> Any {
        return resolvedThemeImage.layerContents(forContentsScale: layerContentsScale)
    }
    
    override open var capInsets: EdgeInsets {
        get {
            return resolvedThemeImage.capInsets
        }
        set {
            resolvedThemeImage.capInsets = newValue
        }
    }
    
    override open var resizingMode: NSImageResizingMode {
        get {
            return resolvedThemeImage.resizingMode
        }
        set {
            resolvedThemeImage.resizingMode = newValue
        }
    }
    
}
