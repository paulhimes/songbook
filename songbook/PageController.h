//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleView.h"

extern NSString * const kStandardTextSizeKey;

@protocol PageControllerDelegate;

@interface PageController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) NSManagedObject *modelObject;
@property (nonatomic, readonly) NSAttributedString *text;
@property (nonatomic, readonly) TitleView *titleView;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, weak) id<PageControllerDelegate> delegate;

- (TitleView *)buildTitleView;

@end

@protocol PageControllerDelegate <NSObject>

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject;

@end