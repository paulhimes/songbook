//
//  BookActivityItemSource.h
//  songbook
//
//  Created by Paul Himes on 4/30/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookActivityItemSource : NSObject <UIActivityItemSource>

- (instancetype)initWithBookFileURL:(NSURL *)bookFileURL;

@end
