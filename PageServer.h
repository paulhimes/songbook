//
//  PageServer.h
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageController.h"
#import "Song.h"

@protocol PageServerDelegate;

@interface PageServer : NSObject <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, weak) id<PageServerDelegate> delegate;
- (PageController *)pageAtIndex:(NSUInteger)index;

@end

@protocol PageServerDelegate <NSObject>

- (void)pageServer:(PageServer *)pageServer contentTitleChangedTo:(NSString *)contentTitle;

@end