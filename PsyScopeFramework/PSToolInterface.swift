//
//  PSToolInterface.swift
//  PsyScopeEditor
//
//  Created by James on 27/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//
//  PSToolInterface.h
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

@objc public protocol PSToolInterface {

//return user friendly unique name of tool
func type() -> String

//return a user firendly small description of tool
func helpfulDescription() -> String

//return an icon for the tool
func icon() -> NSImage

//return a color for the tool
func color() -> NSColor

//called whenever the app needs to show/refresh the properties window, it is the same vc type, do not create a new one, pass the same one
func getPropertiesViewController(entry : Entry, withScript scriptData: PSScriptData) -> PSPluginViewController?

//return the class name (swift isnt good at introspection at the time of writing)
func psclassName() -> String

//creates a link with the object (adding correct attribute)
func createLinkFrom(parent : Entry, to child: Entry, withScript scriptData : PSScriptData) -> Bool

//deletes a link (and ammends appropriate attribute)
func deleteLinkFrom(parent : Entry, to child: Entry, withScript scriptData : PSScriptData) -> Bool

//next is to update an existing entry - this might also mean to create a new one
func updateEntry(realEntry: Entry, withGhostEntry ghostEntry: PSGhostEntry, scriptData: PSScriptData)

//this is the plugins first job in the parsing process - it takes the script and then identifies which entries are it's own.  It should not rely on any of the 'ghostEntry.type' keys as the order it will recieve the script in an indeterminate order.  At the moment, it should check the entry's type before setting it, and if already set, throw its own error - should return PSScriptErrors in array
func identifyEntries(ghostScript: PSGhostScript) -> [PSScriptError]
    
//next is to create the appropariate object from ghost objects - all objects of type are sent here, and should do the same thing as createObject with layout objects etc. the layout objects coords are taken care of later - input array should contain PSGhostEntries*, output LayoutObjects

// should not assume there is a valid experiment object etc
func createObjectWithGhostEntries(entries: [PSGhostEntry], withScript scriptData: PSScriptData) -> [LayoutObject]?

//use this to check that the object has everything it needs before running.  Return an empty array if all is good, otherwise return PSScriptErrors.
func validateBeforeRun(scriptData: PSScriptData) -> [PSScriptError]

//return the initial set up of attributes and entities
//can do whatever it likes to the script and assume there is a valid experiment object
func createObject(scriptData: PSScriptData) -> Entry?

//deletes a given object
func deleteObject(lobject: Entry, withScript scriptData: PSScriptData) -> Bool

//sets whether it can appear in the tool menu
func appearsInToolMenu() -> Bool

//returns true if this item can provide data using it's own functions (e.g. Group Attrib(""))
func isSourceForAttributes() -> Bool

//returns true if you can add attributes to this object
func canAddAttributes() -> Bool

//is called when constructing a menu to allow selection for a source. Give a single root menu item, and set the representedObject to be this tool. Optionally provide a New... option at top (and optionally an Edit...) to allow selection of a source.  Set tags/represented objects to identify what is eventually selected.

//Reserved is to set tag to 1, and represented object to string, in order, and menu selection will set currentValue to that string
//Remember to disable placeholder menu item if no possible selections
func constructAttributeSourceSubMenu(scriptData: PSScriptData) -> NSMenuItem

//when user has selected a menu item, the result will be the new value of the string.
func menuItemSelectedForAttributeSource(itemTitle : String, tag : Int, entry : Entry?, originalValue : String, scriptData: PSScriptData) -> String

//returns array with attributed string representing vary by link, and name of entry
func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String) -> [AnyObject]

//lists valid dragged file extensions (return nil if object cannot be created from dragged file
func validDraggedFileExtensions() -> [String]

//creates from dragged file returns entry if succesfful
func createFromDraggedFile(fileName : String, scriptData: PSScriptData) -> Entry?

//special entries that custom entries should not be named, but are used by this tool
func getReservedEntryNames() -> [String]

//entry names that are fully illegal throughout the script
func getIllegalEntryNames() -> [String]

}



