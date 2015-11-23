//
//  PSAttributesComboBox.swift
//  PsyScopeEditor
//
//  Created by James on 02/08/2014.
//

import Cocoa

let PSPasteboardTypeAttribute : NSString = "psyscope.attribute"

//Handles the attributes browser, and attached combo box
class PSAttributesBrowser: NSObject, NSTableViewDelegate, NSTableViewDataSource, PSEditMenuDelegate, NSPasteboardItemDataProvider {

    //MARK: Outlets
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var elementViewerController : PSElementViewerController!
    
    
    //MARK: Variables
    var content : [Entry] = [] //holds currently displayed attributes
    let addAttributeCellIdentifier = "PSAddAttributeCell"
    let genericInterface = PSAttributeGeneric()
    var attributePicker : PSAttributePicker? //holds a reference to last popup to prevent Zombie object
    var copiedAttribute : Entry? //Holds copied attribute
    var canAddAttributes : Bool = false
    var selectionController : PSSelectionController!

    //MARK: AwakeFromNib
    
    override func awakeFromNib()  {
        let anib = NSNib(nibNamed: "AddAttributeCell", bundle: NSBundle(forClass:self.dynamicType))
        tableView.registerNib(anib!, forIdentifier: addAttributeCellIdentifier)
        self.selectionController = mainWindowController.selectionController
    }
    

    
    //MARK: Attributes refresh
    
    func refresh() {
        if let selectedEntry = selectionController.selectedEntry,
         interface = mainWindowController.scriptData.pluginProvider.getInterfaceForType(PSType.FromName(selectedEntry.type))
            where interface.canAddAttributes() == true {
                
            self.canAddAttributes = true
            let entries = selectedEntry.subEntries.array as! [Entry]
            
            
            
            //get only entries who are not properties
            content = entries.filter({
                (entry : Entry) -> Bool in
                return !entry.isProperty.boolValue
                })
            
            content = content.sort({ (s1: Entry, s2: Entry) -> Bool in
                return s1.name < s2.name })
        } else {
            self.canAddAttributes = false
            content = []
        }
        
        tableView.reloadData()
    }
    
    //MARK: Attributes TableView
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if selectionController != nil && selectionController.selectedEntry != nil && self.canAddAttributes == true {
            return content.count + 1 //add attribute button
        } else {
            return 0 //empty for no selected entry
        }
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < content.count {
            //1. identify attribute type
            var attributeInterface : PSAttributeInterface = genericInterface
            if let interface : PSAttributeInterface = mainWindowController.scriptData.getAttributeInterfaceForAttributeEntry(content[row]) {
                attributeInterface = interface
            }
            
            let attributeParameter = attributeInterface.attributeParameter() as! PSAttributeParameter
            let cell = PSAttributeEntryCellView(entry: content[row], attributeParameter: attributeParameter, interface: genericInterface, scriptData: mainWindowController.scriptData)
            let builder = PSAttributeParameterBuilder(parameter: attributeParameter)
            builder.setupEntryCell(cell)
           
            return cell
        } else {
            //add attribute button
            let new_view  = tableView.makeViewWithIdentifier(addAttributeCellIdentifier, owner: self) as! PSButtonCell
            new_view.action = { (sender : NSButton) -> () in
                self.addAttribute(sender) }
            return new_view
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.attributesTableViewRowHeight
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //show popover
        if row < content.count {
            let view : NSView = tableView.viewAtColumn(0, row: row, makeIfNecessary: true)!
        
            elementViewerController.showForView(view, attributeEntry: content[row])
        
            return true
        } else {
            return false
        }
    }
    
    //MARK: Adding/deleting attributes
    
    @IBAction func addAttribute(sender : NSView) { //from add attribute cell button
        
        if let selectedEntry = selectionController.selectedEntry {
            attributePicker = PSAttributePickerEntry(entry: selectedEntry, scriptData: mainWindowController.scriptData)
            attributePicker!.showAttributeWindow(tableView)
        }
    }
    
    func deleteObject(sender : AnyObject) {
        let index = tableView.selectedRowIndexes.firstIndex
        if index > 0 && index < content.count {
            mainWindowController.scriptData.beginUndoGrouping("Delete Attribute")
            mainWindowController.scriptData.deleteSubEntryFromBaseEntry(content[index].parentEntry, subEntry: content[index])
            mainWindowController.scriptData.endUndoGrouping(true)
        }
        
    }
    
    
    //MARK : Copy/Paste of attributes
    
    func copyObject(sender : AnyObject) {
        let index = tableView.selectedRowIndexes.firstIndex
        if index > 0 && index < content.count {
            let pasteboardItem = NSPasteboardItem()
            let types = [NSPasteboardTypeString, PSPasteboardTypeAttribute]
            var ok = pasteboardItem.setDataProvider(self, forTypes: types)
            if ok {
                let pasteboard = NSPasteboard.generalPasteboard()
                pasteboard.clearContents()
                ok = pasteboard.writeObjects([pasteboardItem])
            }
            
            if (ok) {
                //here remember what was copied in order to paste it
                copiedAttribute = content[index]
            }
        }
    }
    func pasteObject(sender : AnyObject) {
        if let se = selectionController.selectedEntry {
            let pasteboard = NSPasteboard.generalPasteboard()
            let items = pasteboard.readObjectsForClasses([NSPasteboardItem.self], options: [:]) as! [NSPasteboardItem]
            for item in items {
                if let data = item.dataForType(PSPasteboardTypeAttribute  as String) {
                    let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
                    let new_entry = PSCreateEntryFromDictionary(mainWindowController.mainDocument.managedObjectContext!, dict: dict)
                    se.addSubEntriesObject(new_entry)
                }
            }
        }
    }
    
    
    
    func pasteboard(pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
        
        guard let pasteboard = pasteboard else { return }
        
        if let ce = copiedAttribute {
            switch (type) {
            case NSPasteboardTypeString:
                let writer = PSScriptWriter(scriptData: mainWindowController.scriptData)
                
                let string = writer.entryToText(ce, level: 1)
                pasteboard.setString(string, forType: NSPasteboardTypeString)
            case PSPasteboardTypeAttribute:
                let dataDictionary = PSAttributeEntryToNSDictionary(ce)
                let archive = NSKeyedArchiver.archivedDataWithRootObject(dataDictionary)
                pasteboard.setData(archive, forType: PSPasteboardTypeAttribute as String)
            
            default:
                print("Cannot provide data for type : \(type)")
            }
        }
    }
}


