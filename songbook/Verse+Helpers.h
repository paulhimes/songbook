//
//  Verse+Helpers.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//

#import "Verse.h"

@interface Verse (Helpers)

+ (Verse *)verseInContext:(NSManagedObjectContext *)context;

@end
