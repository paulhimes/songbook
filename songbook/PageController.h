//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleView.h"

@protocol PageControllerDelegate;

@interface PageController : UIViewController

@property (nonatomic, readonly) NSManagedObject *modelObject;
@property (nonatomic, readonly) NSAttributedString *text;
@property (nonatomic, readonly) TitleView *titleView;

@property (nonatomic, weak) id<PageControllerDelegate> delegate;

- (TitleView *)buildTitleView;

@end

@protocol PageControllerDelegate <NSObject>

- (void)search;

@end