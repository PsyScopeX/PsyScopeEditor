//
//  PSPluginViewController.m
//  PsyScopeEditor
//
//  Created by James on 04/08/2014.
//

#import "PSPluginViewController.h"

@interface PSPluginViewController ()

@end

@implementation PSPluginViewController

@synthesize entry;
@synthesize scriptData;
@synthesize storedDoubleClickAction;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry *)theEntry scriptData:(PSScriptData *)theScriptData {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.entry = theEntry;
    self.scriptData = theScriptData;
    return self;
}

-(void) doubleClickAction {
    if (storedDoubleClickAction != nil) {
        storedDoubleClickAction();
    }
}

-(void) closeAllWindows{
    
}

-(void) docMocChanged:(NSNotification*)notification {
    
}


@end
