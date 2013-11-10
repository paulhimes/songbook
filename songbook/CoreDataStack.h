//
//  CoreDataStack.h
//  songbook
//
//  Created by Paul Himes on 11/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStack : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithFileURL:(NSURL *)fileURL concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
