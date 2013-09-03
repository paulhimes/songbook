//
//  NSString+Helpers.h
//  songbook
//
//  Created by Paul Himes on 9/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)

- (NSArray *)rangesOfSubstring:(NSString *)substring;
- (NSArray *)wordRangesOfSubstring:(NSString *)substring;

@end
