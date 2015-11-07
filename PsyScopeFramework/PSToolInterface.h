//
//  PSToolInterface.h
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

#import <Cocoa/Cocoa.h>
#import "LayoutObject.h"
#import "Entry.h"
#import "PSPluginViewController.h"

@class PSGhostScript;
@class PSGhostEntry;

@protocol PSToolInterface

//return user friendly unique name of tool
-(NSString*)type;

//return a user firendly small description of tool
-(NSString*)helpfulDescription;

//return an icon for the tool
-(NSImage*)icon;

//return a color for the tool
-(NSColor*)color;

//called whenever the app needs to show/refresh the properties window, it is the same vc type, do not create a new one, pass the same one
-(PSPluginViewController*)getPropertiesViewController:(Entry*)entry withScript:(PSScriptData*)scriptData;

//return the class name (swift isnt good at introspection at the time of writing)
-(NSString*)psclassName;

//creates a link with the object (adding correct attribute)
-(bool) createLinkFrom:(Entry*)parent to:(Entry*)child withScript:(PSScriptData*)scriptData;

//deletes a link (and ammends appropriate attribute)
-(bool) deleteLinkFrom:(Entry*)parent to:(Entry*)child withScript:(PSScriptData*)scriptData;

//next is to update an existing entry - this might also mean to create a new one
-(void) updateEntry:(Entry*)realEntry withGhostEntry:(PSGhostEntry*)ghostEntry scriptData:(PSScriptData*)scriptData;

//this is the plugins first job in the parsing process - it takes the script and then identifies which entries are it's own.  It should not rely on any of the 'ghostEntry.type' keys as the order it will recieve the script in an indeterminate order.  At the moment, it should check the entry's type before setting it, and if already set, throw its own error - should return PSScriptErrors in array
-(NSArray*) identifyEntries:(PSGhostScript*)ghostScript;
//next is to create the appropariate object from ghost objects - all objects of type are sent here, and should do the same thing as createObject with layout objects etc. the layout objects coords are taken care of later - input array should contain PSGhostEntries*, output LayoutObjects

// should not assume there is a valid experiment object etc
-(NSArray*) createObjectWithGhostEntries:(NSArray*)entries withScript:(PSScriptData*)scriptData;

//use this to check that the object has everything it needs before running.  Return an empty array if all is good, otherwise return PSScriptErrors.
-(NSArray*) validateBeforeRun:(PSScriptData*)scriptData;

//return the initial set up of attributes and entities
//can do whatever it likes to the script and assume there is a valid experiment object
-(Entry*) createObject:(PSScriptData*)scriptData;

//deletes a given object
-(bool) deleteObject:(Entry*)entry withScript:(PSScriptData*)scriptData;

//sets whether it can appear in the tool menu
-(bool) appearsInToolMenu;

//returns true if this item can provide data using it's own functions (e.g. Group Attrib(""))
-(bool) isSourceForAttributes;

//returns true if you can add attributes to this object
-(bool) canAddAttributes;

//is called when constructing a menu to allow selection for a source. Give a single root menu item, and set the representedObject to be this tool. Optionally provide a New... option at top (and optionally an Edit...) to allow selection of a source.  Set tags/represented objects to identify what is eventually selected.

    //Reserved is to set tag to 1, and represented object to string, in order, and menu selection will set currentValue to that string
    //Remember to disable placeholder menu item if no possible selections
-(NSMenuItem*) constructAttributeSourceSubMenu:(PSScriptData*)scriptData;

//when user has selected a menu item
-(NSString*) menuItemSelectedForAttributeSource:(NSMenuItem*)menuItem scriptData:(PSScriptData*)scriptData;

//returns array with attributed string representing vary by link, and name of entry
-(NSArray*) identifyAsAttributeSourceAndReturnRepresentiveString:(NSString*)currentValue;

//lists valid dragged file extensions (return nil if object cannot be created from dragged file
-(NSArray*) validDraggedFileExtensions;

//creates from dragged file returns true if succesfful
-(Entry*) createFromDraggedFile: (NSString*)fileName scriptData:(PSScriptData*)scriptData;

//special entries that custom entries should not be named, but are used by this tool
-(NSArray*) getReservedEntryNames;

//entry names that are fully illegal throughout the script
-(NSArray*) getIllegalEntryNames;

@end

