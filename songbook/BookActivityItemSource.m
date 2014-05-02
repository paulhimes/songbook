//
//  BookActivityItemSource.m
//  songbook
//
//  Created by Paul Himes on 4/30/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "BookActivityItemSource.h"

@interface BookActivityItemSource()

@property (nonatomic, strong) NSURL *bookFileURL;

@end

@implementation BookActivityItemSource 

- (instancetype)initWithBookFileURL:(NSURL *)bookFileURL
{
    self = [super init];
    if (self) {
        self.bookFileURL = bookFileURL;
    }
    return self;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.bookFileURL;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.bookFileURL;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return [[self.bookFileURL lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return @"com.paulhimes.songbook.songbook";
}

@end
