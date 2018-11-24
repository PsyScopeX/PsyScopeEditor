//
//  PSToolViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//

import Cocoa

class PSToolTablePropertyController: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView : NSTableView!
    @IBOutlet var tableViewButtons : NSSegmentedControl!
    @IBOutlet var itemsColumn : NSTableColumn!
    @IBOutlet var childTypeViewController : PSChildTypeViewController!
    
    var tableEntry : Entry!
    var stringList : PSStringList!
    var scriptData : PSScriptData!
    let dragReorderType = "PSToolTablePropertyControllerType"
    
    
    func docMocChanged(_ notification: Notification!) {
        refreshView()
    }
    
    override func awakeFromNib() {
        scriptData = childTypeViewController.scriptData
        super.awakeFromNib()
        tableView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([dragReorderType]))
        refreshView()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if stringList != nil {
            return stringList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if stringList != nil && convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(itemsColumn.identifier) && row < stringList.stringListRawUnstripped.count {
            return stringList.stringListRawUnstripped[row]
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(dragReorderType)),
            let rowIndexes : IndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet {
            stringList.move(rowIndexes.first!, to: row)
            return true
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        // Copy the row numbers to the pasteboard.
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([dragReorderType]), owner: self)
        pboard.setData(data, forType: convertToNSPasteboardPasteboardType(dragReorderType))
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        print("\(row) - \(dropOperation.rawValue)")
        if dropOperation == .above {
            return NSDragOperation.move
        } else {
            return NSDragOperation()
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(itemsColumn.identifier) {
            return false
        }
        return true
    }
    
    func refreshView() {
        tableEntry = scriptData.getSubEntry(childTypeViewController.tableEntryName!, entry: childTypeViewController.entry)

        if let te = tableEntry {
            stringList = PSStringList(entry: te, scriptData: scriptData)
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func elementButtons(_ sender : AnyObject) {
        switch (tableViewButtons.selectedSegment) {
        case 0:
            addElement()
        case 1:
            removeElement()
        default:
            break
        }
    }
    
    func addElement() {
        scriptData.beginUndoGrouping("Add New " + childTypeViewController.tableTypeName!)
        var success = false
        if let new_main_entry = scriptData.createNewObjectFromTool(PSType.FromName(childTypeViewController.tableTypeName!))  {
            
            scriptData.createLinkFrom(childTypeViewController.entry, to: new_main_entry, withAttribute: childTypeViewController.tableEntryName!)
            PSPositionNewObject(new_main_entry.layoutObject, scriptData: scriptData) //reposition now link has been made
            success = true
        }
        scriptData.endUndoGrouping(success)
        refreshView()
    }
    
    var selectedElement : String {
        get {
            if stringList != nil {
                let selected_row = tableView.selectedRow
                if stringList.count > 0 && selected_row < 0 {
                    return stringList.stringListRawUnstripped[0]
                }
                if selected_row < stringList.count && selected_row > 0 {
                    return stringList.stringListRawUnstripped[selected_row]
                }
            }
            return ""
        }
    }
    
    func removeElement() {
        //get selected template
        scriptData.beginUndoGrouping("Delete " + childTypeViewController.tableTypeName!)
        let element_to_remove = selectedElement
        var success = false
        for entry in scriptData.getBaseEntries() {
            if entry.name == element_to_remove {
                scriptData.deleteMainEntry(entry)
                success = true
            }
        }
        scriptData.endUndoGrouping(success)
        refreshView()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
