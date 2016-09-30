//
//  UserTheme.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/**
 A `Theme` class wrapping a user provided theme file (`.theme`).
 
 To enable user themes, set theme folder on `ThemeKit.userThemesFolderURL`.

 Notes about `.theme` files:
 
 - lines starting with `#` or `//` will be treated as comments, thus, ignored;
 - non-comment lines consists on simple variable/value assignments (eg, `variable = value`);
 - `variable` name can contain characters `[a-zA-Z0-9_-.]+`;
 - custom variables can be specified (eg, `myBackgroundColor = ...`);
 - theming properties match the class methods of `ThemeColor` and `ThemeGradient` (eg, `labelColor`);
 - variables can be referenced by prefixing them with `$` (eg, `mainBorderColor = $commonBorderColor`);
 - colors are defined using `rgb(255, 255, 255)` or `rgba(255, 255, 255, 1.0)` (case insensitive);
 - gradients are defined using `linear-gradient(color1, color2)` (where colors are defined as above; case insensitive);
 - `ThemeKit.themes` is automatically updated when there are changes on the user themes folder;
 - file changes are applied on-the-fly, if it corresponds to the currently applied theme.
 
 Example `.theme` file:
 
 ```ruby
 // ************************* Theme Info ************************* //
 displayName = My Theme 1
 identifier = com.luckymarmot.ThemeKit.MyTheme1
 darkTheme = true
 
 // ********************* Colors & Gradients ********************* //
 # define color for `ThemeColor.brandColor`
 brandColor = $blue
 # define a new color for `NSColor.labelColor` (overriding)
 labelColor = rgb(11, 220, 111)
 # define gradient for `ThemeGradient.brandGradient`
 brandGradient = linear-gradient($orange.sky, rgba(200, 140, 60, 1.0))
 
 // *********************** Common Colors ************************ //
 blue = rgb(0, 170, 255)
 orange.sky = rgb(160, 90, 45, .5)
 
 // ********************** Fallback Assets *********************** //
 fallbackForegroundColor = rgb(255, 10, 90, 1.0)
 fallbackBackgroundColor = rgb(255, 200, 190)
 fallbackGradient = linear-gradient($blue, rgba(200, 140, 60, 1.0))
 ```
 
 Unimplemented properties on theme file will default to `-fallbackForegroundColor`, 
 `-fallbackBackgroundColor` and  `-fallbackGradient`, for foreground color, 
 background color and gradients, respectively.
 */
@objc(TKUserTheme)
public class UserTheme: NSObject, Theme {
    /// Unique theme identifier.
    public var identifier: String = "{Theme-Not-Loaded}"
    
    /// Theme display name.
    public var displayName: String = "Theme Not Loaded"
    
    /// Theme short display name.
    public var shortDisplayName: String = "Not Loaded"
    
    /// Is this a dark theme?
    public var isDarkTheme: Bool = false
    
    /// Dictionary with key/values pairs read from the .theme file
    private var _keyValues: NSMutableDictionary = NSMutableDictionary();
    
    /// Dictionary with evaluated key/values pairs read from the .theme file
    private var _evaluatedKeyValues: NSMutableDictionary = NSMutableDictionary();
    
    // MARK: -
    // MARK: Initialization
    
    /// `init()` is disabled.
    private override init() {
        super.init()
    }
    
    /// Calling `init(_:)` is not allowed outside this library.
    /// Use `ThemeKit.shared.theme(:_)` instead.
    ///
    /// - parameter themeFileURL: A theme file (`.theme`) URL.
    ///
    /// - returns: An instance of `UserTheme`.
    internal init(_ themeFileURL: URL) {
        super.init()
        
        // Load file
        loadThemeFile(from: themeFileURL)
    }
    
    // MARK: -
    // MARK: Theme Assets
    
    /// Theme asset for the specified key. Supported assets are `NSColor`, `NSGradient` and `NSString`.
    ///
    /// - parameter key: A color name, gradient name or a theme string
    ///
    /// - returns: The theme value for the specified key.
    public func themeAsset(_ key: String) -> Any? {
        var value = _evaluatedKeyValues[key]
        if value == nil {
            value = _keyValues.evaluatedObject(key: key)
            _evaluatedKeyValues.setObject(value, forKey: key as NSString)
        }
        return value
    }
    
    // MARK: -
    // MARK: File
    
    /// Load theme file
    ///
    /// - parameter from: A theme file (`.theme`) URL.
    private func loadThemeFile(from: URL) {
        // Load contents from theme file
        let themeContents = try! String.init(contentsOf: from, encoding: String.Encoding.utf8)
        
        // Split content into lines
        var lineCharset = CharacterSet.init(charactersIn: ";")
        lineCharset.formUnion(CharacterSet.newlines)
        let lines:[String] = themeContents.components(separatedBy: lineCharset)
        
        // Parse lines
        for line in lines {
            // Trim
            let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // Skip comments
            if trimmedLine.hasPrefix("#") || trimmedLine.hasPrefix("//") {
                continue
            }
            
            // Assign theme key-values (lazy evaluation)
            let assignment = trimmedLine.components(separatedBy: "=")
            if assignment.count == 2 {
                let key = assignment[0].trimmingCharacters(in: CharacterSet.whitespaces)
                let value = assignment[1].trimmingCharacters(in: CharacterSet.whitespaces)
                _keyValues.setObject(value, forKey: key as NSString)
            }
        }
        
        // Initialize properties with evaluated values from file
        
        // Identifier
        let _identifier = themeAsset("identifier")
        identifier = _identifier is String ? _identifier as! String : "{identifier: is missing}"
       
        // Display Name
        let _displayName = themeAsset("displayName")
        displayName = _displayName is String ? _displayName as! String : "{displayName: is mising}"
        
        // Short Display Name
        let _shortDisplayName = themeAsset("shortDisplayName")
        shortDisplayName = _shortDisplayName is String ? _shortDisplayName as! String : "{shortDisplayName: is mising}"
        
        // Dark?
        let _isDarkTheme = themeAsset("darkTheme")
        isDarkTheme = _isDarkTheme is String ? NSString(string: (_isDarkTheme as? String)!).boolValue : false
    }
    
    override public var description : String {
        return "<\(UserTheme.self): \(themeDescription(self))>"
    }
}
