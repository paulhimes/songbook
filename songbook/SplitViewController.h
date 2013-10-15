//
//  SplitViewController.h
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitViewController : UIViewController

@property (nonatomic, readonly) UIViewController *master;
@property (nonatomic, readonly) UIViewController *detail;
@property (nonatomic) BOOL masterHidden;

@end

@interface UIViewController (SplitViewController)

@property (nonatomic, weak) SplitViewController *splitController;

@end
