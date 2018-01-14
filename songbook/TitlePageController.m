//
//  TitlePageController.m
//  songbook
//
//  Created by Paul Himes on 8/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageController.h"

@interface TitlePageController ()

@property (nonatomic) BOOL observingTextViewText;
@property (nonatomic, strong) NSNumber *gestureStartTextSize;

@end

@implementation TitlePageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self textContentChanged];
}

- (void)textContentChanged
{
    [super textContentChanged];
        
    // Vertically center the title at the golden ratio. Shift up if the title overflows the container.
    CGFloat desiredVerticalCenter = self.view.bounds.size.height / M_PHI;
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, 0.0)];
    [self.textView setHeight:textSize.height];

    CGFloat halfTextViewHeight = self.textView.frame.size.height / 2.0;
    
    // Frame centered at the golden ratio.
    [self.textView setOriginY:desiredVerticalCenter - halfTextViewHeight];
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        [userDefaults synchronize];
    } else {
        // Scale the existing text size by the gesture recognizer's scale.
        float scaledSize = [self.gestureStartTextSize floatValue] * sender.scale;
        
        // Limit the scaled size to sane bounds.
        float scaledAndLimitedSize = MIN(kMaximumStandardTextSize, MAX(kMinimumStandardTextSize, scaledSize));
        
        if (![@(scaledAndLimitedSize) isEqualToNumber:[userDefaults objectForKey:kStandardTextSizeKey]]) {
            [userDefaults setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
        }
    }
}


@end
