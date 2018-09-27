//
//  Common.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 14/10/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

func CacheKey(selector: Selector) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: nil, theme: nil)
}

func CacheKey(selector: Selector, colorSpace: NSColorSpace?) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: colorSpace, theme: nil)
}

func CacheKey(selector: Selector, theme: Theme?) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: nil, theme: theme)
}

func CacheKey(selector: Selector, colorSpace: NSColorSpace?, theme: Theme?) -> NSNumber {
    var colorSpaceHash: Int = 0
    var themeHash: Int = 0
    
    if let _ = colorSpace {
        colorSpaceHash = (colorSpace!.hashValue << 4)
    }
    if let _ = theme {
        themeHash = (theme!.hash << 8)
    }
    let hashValue = selector.hashValue + colorSpaceHash + themeHash
    return NSNumber(value: hashValue)
}
