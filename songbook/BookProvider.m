//
//  BookProvider.m
//  songbook
//
//  Created by Paul Himes on 1/8/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "BookProvider.h"
#import "BookCodec.h"

@interface BookProvider()

@property (nonatomic, strong) CoreDataStack *coreDataStack;

@end

@implementation BookProvider

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack
{
    self = [super initWithPlaceholderItem:[BookCodec fileURLForExportingFromContext:coreDataStack.managedObjectContext]];
    if (self) {
        self.coreDataStack = coreDataStack;
    }
    return self;
}

- (id)item
{
    NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
    NSURL *exportFileURL = [BookCodec exportBookFromDirectory:bookDirectory];
    return exportFileURL;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return [[self.placeholderItem lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return @"com.paulhimes.songbook.songbook";
}

@end
