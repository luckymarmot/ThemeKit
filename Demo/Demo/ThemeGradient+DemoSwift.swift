//
//  ThemeGradient+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Foundation
import ThemeKit

extension ThemeGradient {
    
    // MARK: CONTENT
    
    /// Rainbow gradient (used between title and text)
    static var rainbowGradient: ThemeGradient? {
        return ThemeGradient.gradient(with: #function)
    }
    
}
