//
//  Section+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Section.h"
#import "Book.h"
#import "SongbookModel.h"

@interface Section (Helpers) <SongbookModel>

+ (Section *)newOrExistingSectionTitled:(NSString *)title inBook:(Book *)book;
+ (Section *)sectionInContext:(NSManagedObjectContext *)context;

@end
