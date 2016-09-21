//
//  Thread+ThemeKit.swift
//  CoreColor
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation

extension Thread {
    
    /// Make sure code block is executed on main thread.
    class func onMain(block: @escaping (Void) -> Void) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
}
