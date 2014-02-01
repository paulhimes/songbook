//
//  Song+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Song.h"
#import "SongbookModel.h"

extern NSString * const kSongNumberRangesKey;
extern NSString * const kTitleRangesKey;
extern NSString * const kNormalRangesKey;
extern NSString * const kSubtitleRangesKey;
extern NSString * const kVerseTitleRangesKey;
extern NSString * const kChorusRangesKey;
extern NSString * const kGhostRangesKey;
extern NSString * const kFooterRangesKey;

@interface Song (Helpers) <SongbookModel>

+ (Song *)newOrExistingSongTitled:(NSString *)title inSection:(Section *)section;
+ (Song *)songInContext:(NSManagedObjectContext *)context;
- (Verse *)addVerse:(NSString *)verseText;

- (void)generateSearchTokensWithCache:(NSCache *)cache;

- (NSString *)string;
- (NSDictionary *)stringComponentRanges;

- (NSString *)headerString;

- (NSString *)description;

- (void)clearCachedSong;

@end
