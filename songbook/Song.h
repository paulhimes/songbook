//
//  Song.h
//  songbook
//
//  Created by Paul Himes on 9/16/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section, Song, TokenInstance, Verse;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * cachedString;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSSet *relatedSongs;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) NSOrderedSet *verses;
@property (nonatomic, retain) NSOrderedSet *tokenInstances;

@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addRelatedSongsObject:(Song *)value;
- (void)removeRelatedSongsObject:(Song *)value;
- (void)addRelatedSongs:(NSSet *)values;
- (void)removeRelatedSongs:(NSSet *)values;

- (void)insertObject:(Verse *)value inVersesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVersesAtIndex:(NSUInteger)idx;
- (void)insertVerses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVersesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVersesAtIndex:(NSUInteger)idx withObject:(Verse *)value;
- (void)replaceVersesAtIndexes:(NSIndexSet *)indexes withVerses:(NSArray *)values;
- (void)addVersesObject:(Verse *)value;
- (void)removeVersesObject:(Verse *)value;
- (void)addVerses:(NSOrderedSet *)values;
- (void)removeVerses:(NSOrderedSet *)values;
- (void)insertObject:(TokenInstance *)value inTokenInstancesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTokenInstancesAtIndex:(NSUInteger)idx;
- (void)insertTokenInstances:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTokenInstancesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTokenInstancesAtIndex:(NSUInteger)idx withObject:(TokenInstance *)value;
- (void)replaceTokenInstancesAtIndexes:(NSIndexSet *)indexes withTokenInstances:(NSArray *)values;
- (void)addTokenInstancesObject:(TokenInstance *)value;
- (void)removeTokenInstancesObject:(TokenInstance *)value;
- (void)addTokenInstances:(NSOrderedSet *)values;
- (void)removeTokenInstances:(NSOrderedSet *)values;
@end
