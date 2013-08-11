//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"

@protocol PageControllerDelegate;

@interface PageController : UIViewController

@property (nonatomic, readonly) NSManagedObject *modelObject;
@property (nonatomic, weak) id<PageControllerDelegate> delegate;

- (PageView *)buildPageView;

@end

@protocol PageControllerDelegate <NSObject>

- (void)pageController:(PageController *)pageController contentTitleChangedTo:(NSAttributedString *)contentTitle;

@end