//
//  BookActivityItemSource.h
//  songbook
//
//  Created by Paul Himes on 4/30/14.
//

#import <Foundation/Foundation.h>

@interface BookActivityItemSource : NSObject <UIActivityItemSource>

- (instancetype)initWithBookFileURL:(NSURL *)bookFileURL;

@end
