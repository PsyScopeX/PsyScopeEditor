//
//  PsyScopeFramework.h
//  PsyScopeFramework
//
//  Created by James on 31/07/2014.
//

//IMPORTANT:
//Remember to make all these headers 'public' rather than 'project' in target membership - otherwise you will get errors.


#import <Cocoa/Cocoa.h>
#import "Entry.h"
#import "LayoutObject.h"
#import "Section.h"
#import "PSPluginInterface.h"
#import "PSToolInterface.h"
#import "PSPluginViewController.h"
#import "Script.h"

#import "PSAttributeInterface.h"
#import "PSDoubleClickAction.h"
#import "PSWindowViewInterface.h"
#import "PSActionInterface.h"
#import "PSConditionInterface.h"

#import "PSSmoothTextLayer.h"

#import "PSSegmentedCell.h"

#import "NSManagedObjectModel+KCOrderedAccessorFix.h"

//! Project version number for PsyScopeFramework.
FOUNDATION_EXPORT double PsyScopeFrameworkVersionNumber;

//! Project version string for PsyScopeFramework.
FOUNDATION_EXPORT const unsigned char PsyScopeFrameworkVersionString[];

FOUNDATION_EXPORT NSString *const PSErrorDomain;

// In this header, you should import all the public headers of your framework using statements like #import <PsyScopeFramework/PublicHeader.h>
