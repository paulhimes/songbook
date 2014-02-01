//
//  BookCodec.h
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookCodec : NSObject

+ (NSURL *)fileURLForExportingFromContext:(NSManagedObjectContext *)context;
+ (void)exportBookFromContext:(NSManagedObjectContext *)context intoURL:(NSURL *)url;
+ (void)importBookFromURL:(NSURL *)file intoContext:(NSManagedObjectContext *)context;

@end
