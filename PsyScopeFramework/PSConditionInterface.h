//
//  PSConditionInterface.h
//  PsyScopeEditor
//
//  Created by James on 02/02/2015.
//

@class PSFunctionElement;

//used for conditions
@protocol PSConditionInterface

//returns type of action
- (NSString*)type;

//return user friendly unique name of attribute
- (NSString*)userFriendlyName;

//return a user firendly small description of attribute
- (NSString*)helpfulDescription;

//return an icon for the tool
-(NSImage*)icon;

-(NSNib*)nib;

//returns height of the cell when expanded
- (CGFloat)expandedCellHeight;

@end
