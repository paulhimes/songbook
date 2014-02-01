//
//  Book+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.


#import "Book.h"
#import "SongbookModel.h"

@interface Book (Helpers) <SongbookModel>

+ (Book *)newOrExistingBookTitled:(NSString *)title inContext:(NSManagedObjectContext *)context;
+ (Book *)bookInContext:(NSManagedObjectContext *)context;
+ (Book *)bookFromContext:(NSManagedObjectContext *)context;

@end
