//
//  Book.h
//  songbook
//
//  Created by Paul Himes on 1/12/14.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * contactEmail;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * updateURL;
@property (nonatomic, retain) NSOrderedSet *sections;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)insertObject:(Section *)value inSectionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSectionsAtIndex:(NSUInteger)idx;
- (void)insertSections:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSectionsAtIndex:(NSUInteger)idx withObject:(Section *)value;
- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)values;
- (void)addSectionsObject:(Section *)value;
- (void)removeSectionsObject:(Section *)value;
- (void)addSections:(NSOrderedSet *)values;
- (void)removeSections:(NSOrderedSet *)values;
@end
