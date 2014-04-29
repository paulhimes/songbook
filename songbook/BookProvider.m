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
@property (nonatomic) BOOL includeExtraFiles;

@end

@implementation BookProvider

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack includeExtraFiles:(BOOL)includeExtraFiles
{
    self = [super initWithPlaceholderItem:[BookCodec fileURLForExportingFromContext:coreDataStack.managedObjectContext]];
    if (self) {
        self.coreDataStack = coreDataStack;
        self.includeExtraFiles = includeExtraFiles;
    }
    return self;
}

- (id)item
{
    NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
    NSURL *exportFileURL = [BookCodec exportBookFromDirectory:bookDirectory includeExtraFiles:self.includeExtraFiles];
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
