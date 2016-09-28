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
        
        ThemeKit.shared.addObserver(self, forKeyPath: "theme", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        ThemeKit.shared.addObserver(self, forKeyPath: "effectiveTheme", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheme(_:)), name: .didChangeTheme, object: nil)
    }

    var themes: [Theme] {
        return ThemeKit.shared.themes
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(themes) {
            willChangeValue(forKey: #keyPath(themes))
            didChangeValue(forKey: #keyPath(themes))
        }
        else if keyPath == "theme" {
//            print("KVO  : theme: \(ThemeKit.shared.theme.identifier)")
        }
        else if keyPath == "effectiveTheme" {
//            print("KVO  : effective theme: \(ThemeKit.shared.effectiveTheme.identifier)")
        }
    }
    
    @objc private func changedTheme(_ notification: Notification) {
//        print("NOTIF: theme: \(ThemeKit.shared.theme.identifier)")
//        print("       effective theme: \(ThemeKit.shared.effectiveTheme.identifier)")
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

