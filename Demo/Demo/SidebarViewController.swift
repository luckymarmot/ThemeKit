//
//  SidebarViewController.swift
//  Demo
//
//  Created by Nuno Grilo on 29/09/2016.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    /// Our outline view
    @IBOutlet var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keep a reference on app delegate
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.sidebarViewController = self
        
        // Load last notes
        loadNotes()
        
        // Save notes on quit & when inactive
        NotificationCenter.default.addObserver(self, selector: #selector(saveNotes), name: .NSApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveNotes), name: .NSApplicationWillResignActive, object: nil)
        
        // Observe note title editing notifications
        NotificationCenter.default.addObserver(forName: .didEditNoteTitle, object: nil, queue: nil) { (notification) in
            self.outlineView.reloadData()
        }
    }
    
    override func viewWillAppear() {
        // Expand root node
        outlineView.expandItem(nil, expandChildren: true)
        
        // Select 1st Note
        outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }
    
    
    // MARK: -
    // MARK: Notes
    
    /// NSUserDefaults key
    let userDefaultsKey: String = "notes"
    
    /// Notes model
    var notes: [Note] = []
    
    /// Load notes
    private func loadNotes(reset: Bool = false) {
        var newNotes: [Note]?
        let userDefaultsNotes = UserDefaults.standard.object(forKey: userDefaultsKey)
        
        if !reset, let pastNotes = userDefaultsNotes as? Data {
            // Load past notes
            let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(with: pastNotes)
            newNotes = unarchivedObject is [Note] ? unarchivedObject as? [Note] : nil
        }
        
        if newNotes == nil {
            // Add some sample Notes to our model
            newNotes = [
                Note(title: "Themes", text: "..:: Light Theme ::..\nDefault, light macOS theme.\n\n..:: Dark Theme ::..\nDark macOS theme, using NSAppearanceNameVibrantDark.\n\n..:: macOS Theme ::..\nDynamically resolve to either the 'Light Theme' or the 'Dark Theme', depending on the macOS preference at 'System Preferences > General > Appearance'.\n\n..:: Paper Theme ::..\nA native 'Theme' defined for this sample application.\n\n..:: Purple Green Theme ::..\nAn user theme ('UserTheme') defined using a '.theme' file. Editing that file will trigger automatic UI refreshes (as long as this is the selected theme).\n"),
                Note(title: "Lorem Ipsum", text: "Lorem ipsum dolor sit amet, his solum antiopam eu, est eu utamur menandri inciderint, eu laudem adipisci eam. Eos euismod apeirian an, quot iusto postulant id cum. Dicit nullam assueverit ne his. Falli constituam ut eam, cu has vitae facilis scribentur, pro ei zril nostro numquam. Est te dicta doctus ullamcorper.\n\nIudico omnesque probatus nec id, eius lorem consequuntur vix ut. Eam graeci laoreet posidonium te, probo possim detraxit eum te. Et vel zril persius pertinacia. Ex delenit persequeris vel, eam no autem molestiae. Volumus sensibus pro at, vel probo timeam ea.\n\nVis wisi nonumy iisque cu. Ponderum abhorreant vis no, oblique tractatos disputando ex mel, an pri placerat deseruisse. An primis intellegebat nec, eam meliore molestie scriptorem ad, affert periculis sit te. At dico elaboraret disputationi eos, inciderint signiferumque has ex. Id vis oblique insolens./n/nAn has ullum omittam, vis etiam disputationi te. Per cu summo utinam neglegentur, eam indoctum philosophia no, ea sea congue discere admodum. Invidunt adipisci ut cum, duis magna audire eu vel. Mea nulla intellegat ad, vis et tibique aliquando./n/nUsu graeco vivendum ex. Partem prodesset per no. Ut usu amet lucilius necessitatibus, hinc dissentias referrentur mei an. Iuvaret molestie expetenda ea quo, clita libris mediocritatem ea duo. Et enim eruditi pro, in vis assum rationibus, case ignota laboramus vel et."),
                Note(title: "Superfruits", text: "- Apples\n- Bananas\n- Grapefruit\n- Blueberries\n- Cantaloupe\n- Cherries\n- Citrus fruits\n- Cranberries\n- Dragon fruit\n- Grapes\n- Blackberries\n- Kiwi\n- Oranges\n- Plums\n- Pomegranate\n- Strawberries\n- Avocados\n- Tomatoes\n- Papayas\n- Raspberries\n- Pumpkin\n- Watermelon\n- Pineapple")
            ]
        }
        
        notes = newNotes!
    }
    
    /// Reset to original notes
    @IBAction override func resetNotes(_ sender: Any){
        loadNotes(reset: true)
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
        outlineView.selectRowIndexes(IndexSet(integer: notes.count), byExtendingSelection: false)
    }
    
    /// Save notes
    @objc private func saveNotes() {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: notes)
        UserDefaults.standard.set(archivedData, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Add a new note
    @IBAction override func addNote(_ sender: NSButton){
        notes.append(Note())
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
        outlineView.selectRowIndexes(IndexSet(integer: notes.count), byExtendingSelection: false)
    }
    
    /// Delete a note
    @IBAction override func deleteNote(_ sender: NSButton){
        if outlineView.selectedRow > 0 && outlineView.selectedRow <= notes.count
            , let note = outlineView.item(atRow: outlineView.selectedRow) as? Note {
            // ask user
            let alert = NSAlert()
            alert.messageText = "Delete \"\(note.title)\"?"
            alert.informativeText = "Are you sure you would like to delete this note?"
            alert.addButton(withTitle: "Delete")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            alert.beginSheetModal(for: view.window!, completionHandler: { (modalResponse) in
                if modalResponse == NSAlertFirstButtonReturn {
                    // delete note
                    self.notes.remove(at: self.outlineView.selectedRow - 1)
                    self.outlineView.reloadData()
                    self.outlineView.expandItem(nil, expandChildren: true)
                    NotificationCenter.default.post(name: .didChangeNoteSelection, object: self, userInfo: nil)
                }
            })
        }
    }
    
    
    // MARK: -
    // MARK: NSOutlineViewDelegate
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        var userInfo: [String: Note]?
        
        if let note = outlineView.item(atRow: outlineView.selectedRow) as? Note {
            // selected a new note
            userInfo = ["note" : note]
        }
        else {
            // cleared selection or selected header
        }
        
        NotificationCenter.default.post(name: .didChangeNoteSelection, object: self, userInfo: userInfo)
    }
    
    
    // MARK: -
    // MARK: NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1;
        }
        else if item is [Note] {
            return notes.count
        }
        return 0;
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is [Note] ? true : false
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (item is [Note])
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return item == nil ? notes as Any : notes[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellView: NSTableCellView?
        
        if item is [Note] {
            cellView = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = "NOTES"
        }
        else {
            cellView = outlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = (item as! Note).title
            cellView?.textField?.textColor = NSColor.labelColor
            cellView?.textField?.delegate = self
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return item is [Note] ? false : true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return item is [Note] ? false : true
    }

    
    // MARK: -
    // MARK: NSTextDelegate
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let note = (control.superview as? NSTableCellView)?.objectValue as? Note
         , let newTitle = (control as? NSTextField)?.objectValue as? String {
            note.title = newTitle
            note.lastModified = Date()
            NotificationCenter.default.post(name: .didEditNoteTitle, object: self, userInfo: ["note" : note])
        }
        return true
    }
}
