//
//  Section.h
//  PsyScopeEditor
//
//  Created by James on 28/11/2014.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Script;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSNumber * scriptOrder;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSOrderedSet *objects;
@property (nonatomic, retain) Script *script;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)insertObject:(Entry *)value inObjectsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromObjectsAtIndex:(NSUInteger)idx;
- (void)insertObjects:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInObjectsAtIndex:(NSUInteger)idx withObject:(Entry *)value;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)values;
- (void)addObjectsObject:(Entry *)value;
- (void)removeObjectsObject:(Entry *)value;
- (void)addObjects:(NSOrderedSet *)values;
- (void)removeObjects:(NSOrderedSet *)values;
@end
