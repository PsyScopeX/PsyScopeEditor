//
//  PSMainWindowViewInterface.h
//  PsyScopeEditor
//
//  Created by James on 06/11/2014.
//


//used to provide a tool bar item and main view to the application
#import <Cocoa/Cocoa.h>
#import "LayoutObject.h"


@protocol PSWindowViewInterface

//before accessing any of the items, make sure to set up by passing scriptData
//and allow to pass messages to selection controller with interface
-(void)setup:(PSScriptData*)scriptData selectionInterface:(id)selectionInterface;

//return a tool bar item for the item
-(NSImage*)icon;

//return a tool bar item for the item
-(NSString*)identifier;

//returns a new tabview item for the central panel
-(NSTabViewItem*)midPanelTab;

//returns a left panel item
-(NSTabViewItem*)leftPanelTab;

//returns name for the type
-(NSString*)type;

//called when an object is deleted
-(void)entryDeleted:(Entry*)entry;

//called to refresh with selected object
-(void)refresh;

@end
