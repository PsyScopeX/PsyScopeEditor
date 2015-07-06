//
//  Entry.h
//  PsyScopeEditor
//
//  Created by James on 08/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, LayoutObject, Script, Section;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSString * currentValue;
@property (nonatomic, retain) NSNumber * isKeyEntry;
@property (nonatomic, retain) NSNumber * isProperty;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * userFriendlyName;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * metaData;
@property (nonatomic, retain) LayoutObject *layoutObject;
@property (nonatomic, retain) LayoutObject *mainEntryFor;
@property (nonatomic, retain) Entry *parentEntry;
@property (nonatomic, retain) Section *parentSection;
@property (nonatomic, retain) Script *script;
@property (nonatomic, retain) NSOrderedSet *subEntries;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)insertObject:(Entry *)value inSubEntriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSubEntriesAtIndex:(NSUInteger)idx;
- (void)insertSubEntries:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSubEntriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSubEntriesAtIndex:(NSUInteger)idx withObject:(Entry *)value;
- (void)replaceSubEntriesAtIndexes:(NSIndexSet *)indexes withSubEntries:(NSArray *)values;
- (void)addSubEntriesObject:(Entry *)value;
- (void)removeSubEntriesObject:(Entry *)value;
- (void)addSubEntries:(NSOrderedSet *)values;
- (void)removeSubEntries:(NSOrderedSet *)values;
@end
