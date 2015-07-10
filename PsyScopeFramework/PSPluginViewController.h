//
//  PSPluginViewController.h
//  PsyScopeEditor
//
//  Created by James on 04/08/2014.
//

#import <Cocoa/Cocoa.h>
#import "Entry.h"
#import "PSDoubleClickAction.h"

@class PSScriptData;

//used for instantiating a view in the properties pane, must keep track of any of it's windows 

typedef void (^PSPluginViewControllerDoubleClick)(void);

@interface PSPluginViewController : NSViewController <PSDoubleClickAction> {
}

@property (readwrite, strong, nonatomic) PSScriptData * scriptData;
@property (readwrite, strong, nonatomic) Entry * entry;
@property (copy) PSPluginViewControllerDoubleClick storedDoubleClickAction;

//This acts as the parent for the nib, and associates an entry (this is optional) and the scriptData with it
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry *)entry scriptData:(PSScriptData*)scriptData;

//When the object is double clicked, bring up a window or something
-(void) doubleClickAction;

//When the object is deleted for instance, override to close all the windows it has brought up
-(void) closeAllWindows;

//called when data is changed
-(void) refresh;

@end