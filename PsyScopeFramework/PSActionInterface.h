//
//  PSActionInterface.h
//  PsyScopeEditor
//
//  Created by James on 15/11/2014.
//



@class PSActionCell; //forward declaration to prevent circular reference
@class PSEventActionFunction;

//used for actions
@protocol PSActionInterface

//returns type of action
- (NSString*)type;

//returns group name of action
- (NSString*)group;

//return user friendly unique name of attribute
- (NSString*)userFriendlyName;

//return a user firendly small description of attribute
- (NSString*)helpfulDescription;

//return an icon for the tool
-(NSImage*)icon;

//creates a cell view that allows editing of the parameters
-(PSActionCell*) createCellView:(PSEventActionFunction*)entryFunction scriptData:(PSScriptData*)scriptData expandedHeight:(CGFloat)expandedHeight;

//returns height of the cell when expanded
- (CGFloat)expandedCellHeight;

@end