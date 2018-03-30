//
//  DetailsView.swift
//  Demo
//
//  Created by Nuno Grilo on 30/09/2016.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
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
        let imageSize = NSSize(width: 48, height: 48)
        ThemeImage.detailsImage.draw(in: NSRect(x: (bounds.width - imageSize.width) / 2, y: bounds.height - 56, width: imageSize.width, height: imageSize.height))
    }

}
