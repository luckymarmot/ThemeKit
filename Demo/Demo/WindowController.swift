//
//  WindowController.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa
import ThemeKit

class WindowController: NSWindowController {
    
    @IBOutlet weak var sidebarViewController: SidebarViewController!
    
    public var themeKit: ThemeKit = ThemeKit.shared
    
}
