//
//  ExportProgressViewController.h
//  songbook
//
//  Created by Paul Himes on 5/2/14.
//

#import <UIKit/UIKit.h>

@protocol ExportProgressViewControllerDelegate;

@interface ExportProgressViewController : UIViewController

@property (nonatomic, strong) id <ExportProgressViewControllerDelegate> delegate;

- (void)setProgress:(CGFloat)progress;
- (void)showWithCompletion:(void (^)(void))completion;
- (void)hideWithCompletion:(void (^)(void))completion;

@end

@protocol ExportProgressViewControllerDelegate <NSObject>

- (void)exportProgressViewControllerDidCancel:(ExportProgressViewController *)exportProgressViewController;

@end
