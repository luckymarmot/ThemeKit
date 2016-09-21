//
//  ViewController.swift
//  DemoSwift
//
//  Created by Nuno Grilo on 07/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeKit.shared.addObserver(self, forKeyPath: #keyPath(themes), options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        
        let userDefaultsTheme = UserDefaults.standard.string(forKey: "ThemeKitTheme")
        print("userDefaultsTheme: \(userDefaultsTheme)")
    }

    var themes: [Theme] {
        return ThemeKit.shared.themes
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(themes) else { return }
        
        willChangeValue(forKey: #keyPath(themes))
        didChangeValue(forKey: #keyPath(themes))
    }
    
}

class CustomView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        // Draw solid color
        let leftFrame = NSMakeRect(0, 0, bounds.size.width/2, bounds.size.height)
        ThemeColor.brandColor.setFill()
        NSBezierPath(rect: leftFrame).fill()
        
        // Draw gradient
        let rightFrame = NSMakeRect(bounds.size.width/2 + 1, 0, bounds.size.width - bounds.size.width/2 + 1, bounds.size.height)
        ThemeGradient.brandGradient.draw(in: rightFrame, angle: 90)
    }
    
}

