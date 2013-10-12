//
//  SafeTextView.m
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SafeTextView.h"

@implementation SafeTextView

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (self.contentOffsetCallsDisabled) {
        return;
    }
    
    [super setContentOffset:contentOffset animated:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (self.contentOffsetCallsDisabled) {
        return;
    }
    
    [super setContentOffset:contentOffset];
}

- (void)forceContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

@end
