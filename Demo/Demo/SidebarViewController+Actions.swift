//
//  NSViewController+GlobalActions.swift
//  Demo
//
//  Created by Nuno Grilo on 01/10/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    @IBAction func addNote(_ sender: NSButton) {
        forwardActionToSidebarViewController(#selector(addNote(_:)), with: sender)
    }
    
    @IBAction func deleteNote(_ sender: NSButton) {
        forwardActionToSidebarViewController(#selector(deleteNote(_:)), with: sender)
    }
    
}



extension NSWindowController {
    
    @IBAction func addNote(_ sender: NSButton) {
        forwardActionToSidebarViewController(#selector(addNote(_:)), with: sender)
    }
    
    @IBAction func deleteNote(_ sender: NSButton) {
        forwardActionToSidebarViewController(#selector(deleteNote(_:)), with: sender)
    }
    
}


extension NSResponder {

    func forwardActionToSidebarViewController(_ selector: Selector, with sender:Any?) {
        // resign firstResponder on text view
        NSApp.mainWindow?.makeFirstResponder(nil)
        
        // start with a view controller
        var responder: NSResponder = self
        if responder is NSWindowController {
            responder = (responder as! NSWindowController).contentViewController!
        }
        
        // forward action to splitview firstResponder
        if !(tryAction(responder, selector: selector, with: sender)) {
            while responder.nextResponder != nil {
                responder = responder.nextResponder!
                if tryAction(responder, selector: selector, with: sender) {
                    break
                }
            }
        }
    }
    
    func tryAction(_ responder:NSResponder, selector: Selector, with sender:Any?) -> Bool {
        if responder is NSSplitViewController {
            for item in (responder as! NSSplitViewController).splitViewItems {
                if item.viewController.try(toPerform: selector, with: sender) {
                    return true
                }
            }
        }
        return false
    }
    
    
}
