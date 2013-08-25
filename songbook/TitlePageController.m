//
//  TitlePageController.m
//  songbook
//
//  Created by Paul Himes on 8/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageController.h"

static const NSInteger kTopMargin = 16;

@interface TitlePageController ()

@end

@implementation TitlePageController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Vertically center the title at the golden ratio. Shift up if the title overflows the container.
    CGFloat desiredVerticalCenter = self.view.bounds.size.height / M_PHI;
    CGFloat halfTextViewHeight = self.textView.frame.size.height / 2.0;
    
    if (desiredVerticalCenter - halfTextViewHeight < kTopMargin) {
        // Frame top aligned.
        [self.textView setOriginY:kTopMargin];
    } else {
        // Frame centered at the golden ratio.
        [self.textView setOriginY:desiredVerticalCenter - halfTextViewHeight];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom), CGRectGetMaxY(self.textView.frame)));
}

@end
