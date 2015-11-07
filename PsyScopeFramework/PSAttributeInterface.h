//
//  PSAttributeInterface.h
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//
#import <Cocoa/Cocoa.h>


@class PSGhostScript;
@class PSGhostEntry;
@class PSCellView;

typedef NS_ENUM(NSInteger, PSAttributeDialogType) {
    PSAttributeDialogTypeText,
    PSAttributeDialogTypeFileOpen,
    PSAttributeDialogTypeFileSave,
    PSAttributeDialogTypeFloat,
    PSAttributeDialogTypeInt,
    PSAttributeDialogTypeCustom,
    PSAttributeDialogTypeFontStyle,
    PSAttributeDialogTypeFontType,
    PSAttributeDialogTypeFontSize,
    PSAttributeDialogTypeFontFace,
    PSAttributeDialogTypeColor,
    PSAttributeDialogTypeMode
    
} ;

@protocol PSAttributeInterface

//return user friendly unique name of attribute
- (NSString*)userFriendlyName;

//return a user firendly small description of attribute
- (NSString*)helpfulDescription;

//return the code attribute name for the attribute
- (NSString*)codeName;


//return the class name (swift isnt good at introspection at the time of writing)
- (NSString*)psclassName;

//returns the unique values that this object creates and manages
- (NSArray*)keyValues;

//returns the classNames of the tools the Attribute is appropriate for
- (NSArray*)tools;

//returns the default value of the attribute when instatiated
- (NSString*)defaultValue;

//returns the attributeParameter
- (id) attributeParameter;

//this is the plugins first job in the parsing process - it takes the script and then identifies which entries are it's own.  It should not rely on any of the 'ghostEntry.type' keys as the order it will recieve the script in an indeterminate order.  At the moment, it should check the entry's type before setting it, and if already set, throw its own error - should return PSScriptErrors in array
-(NSArray*) identifyEntries:(PSGhostScript*)ghostScript;
//next is to create the appropariate object from ghost objects - all objects of type are sent here, and should do the same thing as createObject with layout objects etc. the layout objects coords are taken care of later - input array should contain PSGhostEntries*, output LayoutObjects 
-(NSArray*) createBaseEntriesWithGhostEntries:(NSArray*)entries withScript:(PSScriptData*)scriptData;

//next is to update an existing entry - this might also mean to create a new one
-(void) updateEntry:(Entry*)realEntry withGhostEntry:(PSGhostEntry*)ghostEntry scriptData:(PSScriptData*)scriptData;

//special entries that custom entries should not be named, but are used by this tool
-(NSArray*) getReservedEntryNames;

//entry names that are fully illegal throughout the script
-(NSArray*) getIllegalEntryNames;

@end
