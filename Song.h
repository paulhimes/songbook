//
//  Song.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section, Song;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) NSOrderedSet *verses;
@property (nonatomic, retain) NSSet *relatedSongs;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inVersesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVersesAtIndex:(NSUInteger)idx;
- (void)insertVerses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVersesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVersesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceVersesAtIndexes:(NSIndexSet *)indexes withVerses:(NSArray *)values;
- (void)addVersesObject:(NSManagedObject *)value;
- (void)removeVersesObject:(NSManagedObject *)value;
- (void)addVerses:(NSOrderedSet *)values;
- (void)removeVerses:(NSOrderedSet *)values;
- (void)addRelatedSongsObject:(Song *)value;
- (void)removeRelatedSongsObject:(Song *)value;
- (void)addRelatedSongs:(NSSet *)values;
- (void)removeRelatedSongs:(NSSet *)values;

@end
