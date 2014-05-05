//
//  ExportProgressViewController.h
//  songbook
//
//  Created by Paul Himes on 5/2/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExportProgressViewControllerDelegate;

@interface ExportProgressViewController : UIViewController

@property (nonatomic, strong) id <ExportProgressViewControllerDelegate> delegate;

- (void)setProgress:(CGFloat)progress;
- (void)showWithCompletion:(void (^)())completion;
- (void)hideWithCompletion:(void (^)())completion;

@end

@protocol ExportProgressViewControllerDelegate <NSObject>

- (void)exportProgressViewControllerDidCancel:(ExportProgressViewController *)exportProgressViewController;

@end
