//
//  NSDictionary+UserTheme.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

private var varsRegExpr: NSRegularExpression!
private var colorRegExpr: NSRegularExpression!
private var linearGradRegExpr: NSRegularExpression!

extension NSDictionary {
    
    // MARK: Initialization
    
    /// Initialize `NSRegularExpression`
    open override class func initialize() {
        // Regular expression for user theme variables ($var)
        do {
            varsRegExpr = try NSRegularExpression.init(pattern: "(\\$[a-zA-Z0-9_\\-\\.]+)+", options: .caseInsensitive)
        }
        catch let error {
            print(error)
        }
        
        // Regular expression for user theme colors
        do {
            colorRegExpr = try NSRegularExpression.init(pattern: "(?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?([0-1]?(?:\\.\\d+)?)", options: .caseInsensitive)
        }
        catch let error {
            print(error)
        }
        
        // Regular expression for user theme gradients
        do {
            linearGradRegExpr = try NSRegularExpression.init(pattern: "linear-gradient\\(\\s*((?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]*[\\s+]?([0-1]?(?:\\.\\d+)?)\\))\\s*,\\s*((?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]*[\\s+]?([0-1]?(?:\\.\\d+)?)\\))\\s*\\)", options: .caseInsensitive)
        }
        catch let error {
            print(error)
        }
    }
    
    // MARK: Evaluation
    
    /// Evaluate object for the specified key as theme asset (`NSColor`, `NSGradient`, ...).
    func evaluatedObject(key: String) -> AnyObject! {
        // Resolve any variables
        let stringValue = evaluatedString(key: key)
        
        // Evaluate as theme asset (NSColor, NSGradient, ...)
        return evaluatedObjectAsThemeAsset(value: stringValue as AnyObject)
    }
    
    // MARK: Internal evaluation functions
    
    /// Evaluate object for the specified key as string.
    private func evaluatedString(key: String) -> String! {
        guard self[key] != nil else {
            return nil
        }
        
        var value = self[key] as! String
        if self[key] is String {
            var stringValue = (self[key] as! String)
            
            // Resolve any variables
            var rangeOffset = 0
            varsRegExpr.enumerateMatches(in: stringValue, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSMakeRange(0, stringValue.characters.count), using: { (match, flags, stop) in
                var range = match?.rangeAt(1)
                range?.location += rangeOffset
                
                // Extract variable
                let start = range!.location + 1
                let end = start + range!.length - 2
                let variable = value[start..<end]
                
                // Evaluated value
                var variableValue = evaluatedString(key: variable)
                if variableValue != nil {
                    value = value.replacingCharacters(inNSRange: range!, with: variableValue!)
                
                    // Move offset forward
                    rangeOffset = variableValue!.characters.count - (range?.length)!
                }
                else {
                    // Move offset forward
                    rangeOffset = (range?.length)!
                }
            })
        }
        return value
    }
    
    /// Evaluate object as theme asset (`NSColor`, `NSGradient`, ...).
    private func evaluatedObjectAsThemeAsset(value: AnyObject) -> AnyObject {
        var object = value
        if (object is String) {
            var stringValue = (object as! String)
            
            // linear-gradient(color1, color2)
            let match = linearGradRegExpr.firstMatch(in: stringValue, options:NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSMakeRange(0, stringValue.characters.count))
            if match?.numberOfRanges == 11 {
                // Starting color
                let red1 = Float(stringValue.substring(withNSRange: match!.rangeAt(2)))! / 255
                let green1 = Float(stringValue.substring(withNSRange: match!.rangeAt(3)))! / 255
                let blue1 = Float(stringValue.substring(withNSRange: match!.rangeAt(4)))! / 255
                let alpha1 = Float(stringValue.substring(withNSRange: match!.rangeAt(5))) ?? 1.0
                let color1 = NSColor(red: CGFloat(red1), green: CGFloat(green1), blue: CGFloat(blue1), alpha: CGFloat(alpha1))

                // Ending color
                let red2 = Float(stringValue.substring(withNSRange: match!.rangeAt(7)))! / 255
                let green2 = Float(stringValue.substring(withNSRange: match!.rangeAt(8)))! / 255
                let blue2 = Float(stringValue.substring(withNSRange: match!.rangeAt(9)))! / 255
                let alpha2 = Float(stringValue.substring(withNSRange: match!.rangeAt(10))) ?? 1.0
                let color2 = NSColor(red: CGFloat(red2), green: CGFloat(green2), blue: CGFloat(blue2), alpha: CGFloat(alpha2))
                
                // Gradient
                object = NSGradient(starting: color1, ending: color2)!
            }
            
            // rgb/rgba color
            if (object is String) {
                var stringValue = (object as! String)
                let match = colorRegExpr.firstMatch(in: stringValue, options:NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSMakeRange(0, stringValue.characters.count))
                if match?.numberOfRanges == 5 {
                    let red = Float(stringValue.substring(withNSRange: match!.rangeAt(1)))! / 255
                    let green = Float(stringValue.substring(withNSRange: match!.rangeAt(2)))! / 255
                    let blue = Float(stringValue.substring(withNSRange: match!.rangeAt(3)))! / 255
                    let alpha = Float(stringValue.substring(withNSRange: match!.rangeAt(4))) ?? 1.0
                    
                    // Color
                    object = NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
                }
            }
            
        }
        
        return object
    }
    
}
