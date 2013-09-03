//
//  Song+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Song.h"
#import "Verse.h"
#import "SongbookModel.h"

@interface Song (Helpers) <SongbookModel>

+ (Song *)newOrExistingSongTitled:(NSString *)title inSection:(Section *)section;
+ (Song *)songInContext:(NSManagedObjectContext *)context;
- (Verse *)addVerse:(NSString *)verseText;

- (NSString *)stringForSearching;
- (NSString *)headerString;

@end
