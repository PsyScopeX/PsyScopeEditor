//
//  PSAttributePicker.swift
//  PsyScopeEditor
//
//  A class which shows a popover window, next to the view given to it when you run showAttributeWindow.  Before running this method, set selectAttributeFunction block to cause whatever changes are necessary from the window.  ExistingAttributes holds the text names of the attributes it currently has
import Cocoa

//MARK: PSAttributePicker

public class PSAttributePicker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.categories = PSAttributePickerCategories(scriptData)
        self.tableCellViewIdentifier = "PSAttributePickerCell"
        super.init()
        NSBundle(forClass:self.dynamicType).loadNibNamed("AttributePicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    
    // MARK: Variables / Constants
    let scriptData : PSScriptData
    let categories : [PSAttributePickerCategory]
    let tableCellViewIdentifier : String
    
    var topLevelObjects : NSArray?
    var tableViewAttributes : [PSAttributePickerAttribute] = []
    var existingAttributes : [PSAttributeType] = []
    
    // MARK: Outlets
    
    @IBOutlet var attributeTableView : NSTableView!
    @IBOutlet var popover : NSPopover!
    @IBOutlet var attributePopupButton : NSPopUpButton!
    
    // MARK: Setup and Start
    
    override public func awakeFromNib() {
        let nib = NSNib(nibNamed: "AttributePickerCell", bundle: NSBundle(forClass:self.dynamicType))
        attributeTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        
        //put categories into popup menu
        var menu_items : [String] = []
        for type in categories {
            menu_items.append(type.userFriendlyName)
        }
        attributePopupButton.removeAllItems()
        attributePopupButton.addItemsWithTitles(menu_items)
        self.existingAttributes = []
    }
    
    public func showAttributeWindow(view : NSView) {
        popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MinX)
        selectCategory(self)
    }
    
    
    // MARK: User interaction

    @IBAction func selectCategory(sender : AnyObject) {
        
        tableViewAttributes = []
        
        //get type selected
        let currentSelectedTitle = self.attributePopupButton.selectedItem?.title
        let selected_category = categories.filter({ $0.userFriendlyName == currentSelectedTitle }).first!
        
        //show just the relevent attributes
        for (_, a_plugin) in scriptData.pluginProvider.attributePlugins {
            let valid_types = a_plugin.tools() as! [String]
            
            for tool_type in valid_types {
                if tool_type == selected_category.name {
                    //attribute is applicable to this tool
                    var new_attribute = PSAttributePickerAttribute()
                    new_attribute.userFriendlyName = a_plugin.userFriendlyName()
                    new_attribute.helpfulDescription = a_plugin.helpfulDescription()
                    new_attribute.attribute = a_plugin
                    new_attribute.type = PSAttributeType(name: a_plugin.codeName(), parentType: PSType.FromName(tool_type))
                    tableViewAttributes.append(new_attribute)
                }
            }
        }
        
        tableViewAttributes = tableViewAttributes.sort({ (s1: PSAttributePickerAttribute, s2: PSAttributePickerAttribute) -> Bool in
            return s1.userFriendlyName < s2.userFriendlyName })
        attributeTableView.reloadData()
    }
    
    @IBAction func doneButtonClicked(sender : AnyObject) {
        popover.close()
    }
    
    func attributeButtonClicked(row : Int, clickedOn : Bool) {
        let type = tableViewAttributes[row].type
        if clickedOn {
            self.existingAttributes.append(type)
        } else {
            if let index = self.existingAttributes.indexOf(type) {
                self.existingAttributes.removeAtIndex(index)
            }
        }
    }
    
    // MARK: TableView
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableViewAttributes.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //make view
        let view = tableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: nil) as! PSAttributePickerCell
        view.setup(tableViewAttributes[row].userFriendlyName, row: row, clickCallback: attributeButtonClicked)
        
        //preset checkbox state
        view.button.state = existingAttributes.contains(tableViewAttributes[row].type) ? 1 : 0
        
        return view
    }
    
    public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(25)
    }
    
}

//MARK: Struct

struct PSAttributePickerAttribute  {
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
    var type : PSAttributeType = PSAttributeType.init(fullType: "")
    var attribute : PSAttributeInterface! = nil
}
