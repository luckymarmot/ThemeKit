//: Playground - noun: a place where people can play

import Cocoa
import ThemeKit

var str = "Hello, playground"

extension ThemeColor {
    
    static var brandColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
    public static override var labelColor: ThemeColor {
        return ThemeColor.color(with: #function)
    }
    
}


ThemeColor.brandColor
