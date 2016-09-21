//
//  DefaultThemeValueTransformer.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import ThemeKit


class DefaultThemeValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return value ?? ThemeKit.shared.defaultTheme.identifier
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let type = value as? NSString else { return nil }
        return type
    }
    
}
