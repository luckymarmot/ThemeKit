//
//  ThemeGradient+DemoSwift.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 08/09/16.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Foundation
import ThemeKit

extension ThemeGradient {

    // MARK: CONTENT

    /// Rainbow gradient (used between title and text)
    @objc static var rainbowGradient: ThemeGradient? {
        return ThemeGradient.gradient(with: #function)
    }

}
