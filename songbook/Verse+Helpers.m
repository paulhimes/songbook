//
//  Verse+Helpers.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Verse+Helpers.h"

@implementation Verse (Helpers)

+ (Verse *)verseInContext:(NSManagedObjectContext *)context
{
    return (Verse *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Verse"
                                                                        inManagedObjectContext:context]
                             insertIntoManagedObjectContext:context];
}

@end
