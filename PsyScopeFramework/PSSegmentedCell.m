//
//  PSSegmentedCell.m
//  PsyScopeEditor
//
//  Created by James on 17/11/2014.
//

#import "PSSegmentedCell.h"

@implementation PSSegmentedCell

- (SEL)action
{
    //this allows connected menu to popup instantly (because no action is returned for menu button)
    if ([self tagForSegment:[self selectedSegment]]==0) {
        return nil;
    } else {
        return [super action];
    }
}
@end
