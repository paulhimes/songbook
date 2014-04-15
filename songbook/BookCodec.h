//
//  BookCodec.h
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataStack.h"

@interface BookCodec : NSObject

+ (NSURL *)fileURLForExportingFromContext:(NSManagedObjectContext *)context;
+ (NSURL *)exportBookFromDirectory:(NSURL *)directory;
+ (void)importBookFromURL:(NSURL *)file intoDirectory:(NSURL *)directory;
+ (CoreDataStack *)coreDataStackFromBookDirectory:(NSURL *)directory concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
