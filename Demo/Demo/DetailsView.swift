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
        // Fill with details background
        ThemeColor.detailsBackgroundColor.set()
        NSBezierPath(rect: bounds).fill()
        
        // Draw theme details image
        let imageSize = NSMakeSize(48, 48)
        ThemeImage.detailsImage.draw(in: NSMakeRect((NSWidth(bounds) - imageSize.width) / 2, NSHeight(bounds) - 56, imageSize.width, imageSize.height))
    }
    
}
