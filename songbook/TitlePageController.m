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
    
    [self.textView setDebugColor:[UIColor greenColor]];
    
    // Vertically center the title at the golden ratio. Shift up if the title overflows the container.
    CGFloat desiredVerticalCenter = self.view.bounds.size.height / M_PHI;
    
    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)
                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                             context:nil];
    [self.textView setHeight:textRect.size.height * 2];
    
    CGFloat halfTextViewHeight = textRect.size.height / 2.0;

    if (desiredVerticalCenter - halfTextViewHeight < kTopMargin) {
        // Frame top aligned.
        [self.textView setOriginY:kTopMargin];
    } else {
        // Frame centered at the golden ratio.
        [self.textView setOriginY:desiredVerticalCenter - halfTextViewHeight];
    }
}

@end
