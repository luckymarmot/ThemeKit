//
//  UserTheme.swift
//  CoreColor
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

/**
 A `Theme` class that wraps a user provided theme file (`.theme`).
 Theme folder is configured on `ThemeKit.shared.userThemesFolderURL`.

 Theme file format:
 
 - lines starting with # or // will be treated as comments thus ignored
 - remaining lines are simple variable/value assignments (eg, `variable = value`)
 - custom variables can be specified (eg, `myVar1 = ...`)
 - theming properties match the class methods of `ThemeColor` and `ThemeGradient` (eg, `mainBorderColor`)
 - variables can be reused by prefixing them with `$` (eg, `mainBorderColor = $lineNumberTextColor`)
 - colors are defined using `rgb(255, 255, 255)` or `rgba(255, 255, 255, 1.0)` (case insensitive)
 - gradients are defined using `linear-gradient(color1, color2)` (where colors are defined as above; case insensitive)
 
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
    
    
    // MARK:- Initialization
    
    /// `init()` is disabled.
    private override init() {
        super.init()
    }
    
    /// Calling `init(_:)` is not allowed outside this library.
    /// Use `ThemeKit.shared.theme(:_)` instead.
    internal init(_ themeFileURL: URL) {
        super.init()
        
        // Load file
        loadThemeFile(from: themeFileURL)
    }
    
    
    // MARK:- Theming
    
    /// Theme asset for the specified key. Supported assets are `NSColor`, `NSGradient` and `NSString`.
    public func themeAsset(_ key: String) -> Any? {
        var value = _evaluatedKeyValues[key]
        if value == nil {
            value = _keyValues.evaluatedObject(key: key)
            _evaluatedKeyValues.setObject(value, forKey: key as NSString)
        }
        return value
    }
    
    // MARK:- File
    
    /// Load theme file
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
