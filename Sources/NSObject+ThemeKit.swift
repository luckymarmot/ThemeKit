//
//  NSObject+ThemeKit.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 24/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// Swizzle instance methods
    internal class func swizzleInstanceMethod(cls: AnyClass?, selector originalSelector: Selector, withSelector swizzledSelector: Selector) {
        guard cls != nil else {
            print("Unable to swizzle \(cls).\(originalSelector): dynamic system color override will not be available.")
            return
        }
        
        // methods
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        
        // add new method
        let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        // switch implementations
        if didAddMethod {
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    /// Returns class method names
    internal class func classMethodNames(for cls: AnyClass?) -> Array<String> {
        var results: Array<String> = []
        
        // retrieve class method list
        var count: UInt32 = 0
        let methods : UnsafeMutablePointer<Method?>! = class_copyMethodList(object_getClass(cls), &count)
        
        // iterate class methods
        for i in 0..<count {
            let name = NSStringFromSelector(method_getName(methods[Int(i)]))
            results.append(name)
        }
        
        // release class methods list
        free(methods)
        
        return results
    }
    
}
