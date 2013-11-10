//
//  BookCodec.h
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book+Helpers.h"

@interface BookCodec : NSObject

+ (NSURL *)exportBookFromContext:(NSManagedObjectContext *)context;
+ (void)importBookFromURL:(NSURL *)file intoContext:(NSManagedObjectContext *)context;

@end
