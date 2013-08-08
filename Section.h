//
//  Section.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Book *book;
@property (nonatomic, retain) NSOrderedSet *songs;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inSongsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSongsAtIndex:(NSUInteger)idx;
- (void)insertSongs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSongsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSongsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceSongsAtIndexes:(NSIndexSet *)indexes withSongs:(NSArray *)values;
- (void)addSongsObject:(NSManagedObject *)value;
- (void)removeSongsObject:(NSManagedObject *)value;
- (void)addSongs:(NSOrderedSet *)values;
- (void)removeSongs:(NSOrderedSet *)values;
@end
