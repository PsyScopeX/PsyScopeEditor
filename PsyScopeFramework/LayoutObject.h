//
//  LayoutObject.h
//  PsyScopeEditor
//
//  Created by James on 13/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, LayoutObject;

@interface LayoutObject : NSManagedObject

@property (nonatomic, retain) id icon;
@property (nonatomic, retain) NSNumber * xPos;
@property (nonatomic, retain) NSNumber * yPos;
@property (nonatomic, retain) NSOrderedSet *childLink;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) Entry *mainEntry;
@property (nonatomic, retain) NSSet *parentLink;
@end

@interface LayoutObject (CoreDataGeneratedAccessors)

- (void)insertObject:(LayoutObject *)value inChildLinkAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildLinkAtIndex:(NSUInteger)idx;
- (void)insertChildLink:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildLinkAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildLinkAtIndex:(NSUInteger)idx withObject:(LayoutObject *)value;
- (void)replaceChildLinkAtIndexes:(NSIndexSet *)indexes withChildLink:(NSArray *)values;
- (void)addChildLinkObject:(LayoutObject *)value;
- (void)removeChildLinkObject:(LayoutObject *)value;
- (void)addChildLink:(NSOrderedSet *)values;
- (void)removeChildLink:(NSOrderedSet *)values;
- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

- (void)addParentLinkObject:(LayoutObject *)value;
- (void)removeParentLinkObject:(LayoutObject *)value;
- (void)addParentLink:(NSSet *)values;
- (void)removeParentLink:(NSSet *)values;

@end
