//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafeTextView.h"

extern NSString * const kStandardTextSizeKey;
extern const float kSuperMaximumStandardTextSize;
extern const float kMaximumStandardTextSize;
extern const float kMinimumStandardTextSize;

@protocol PageControllerDelegate;

@interface PageController : UIViewController

@property (nonatomic, readonly) NSManagedObject *modelObject;
@property (nonatomic, weak) id<PageControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet SafeTextView *textView;
@property (nonatomic, readonly) NSAttributedString *text;
@property (nonatomic) NSRange highlightRange;

- (void)handleGesture:(UIPinchGestureRecognizer *)sender;

@end

@protocol PageControllerDelegate <NSObject>

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject;
- (void)search;

@end