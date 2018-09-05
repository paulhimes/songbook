//
//  TokenizeOperation.h
//  songbook
//
//  Created by Paul Himes on 11/6/13.
//

#import <Foundation/Foundation.h>
#import "Book.h"

extern NSString * const kTokenizeProgressNotification;
extern NSString * const kBookIDKey;
extern NSString * const kCompletedSongCountKey;
extern NSString * const kTotalSongCountKey;

@interface TokenizeOperation : NSOperation

- (instancetype)initWithBook:(Book *)book;

@end
