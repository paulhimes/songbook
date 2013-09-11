//
//  BookParser.h
//  songbook
//
//  Created by Paul Himes on 9/9/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface BookParser : NSObject

- (NSArray *)songsFromFilePath:(NSString *)path;


@end
