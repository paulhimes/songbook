//
//  BookCodec.h
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//

#import <Foundation/Foundation.h>
#import "CoreDataStack.h"

@interface BookCodec : NSObject

+ (NSURL *)fileURLForExportingFromContext:(NSManagedObjectContext *)context;
+ (NSURL *)exportBookFromDirectory:(NSURL *)directory includeExtraFiles:(BOOL)includeExtraFiles progress:(void (^)(CGFloat progress, BOOL *stop))progress;
+ (void)importBookFromURL:(NSURL *)file intoDirectory:(NSURL *)directory;
+ (CoreDataStack *)coreDataStackFromBookDirectory:(NSURL *)directory concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
