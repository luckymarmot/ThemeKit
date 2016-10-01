//
//  DetailsView.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class DetailsView: NSView {
    
    /// Drawing code
    override func draw(_ dirtyRect: NSRect) {
        // Draw vertical gradient
        ThemeGradient.detailsGradient.draw(in: bounds, angle: 270)
    }
    
}
