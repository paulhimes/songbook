//
//  Verse+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Verse.h"

@interface Verse (Helpers)

+ (Verse *)verseInContext:(NSManagedObjectContext *)context;

@end
