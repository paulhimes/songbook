//
//  TitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitleView.h"

const CGFloat kMinimumTitleViewHeight = 44;

@implementation TitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (void)layoutSubviews
//{
//    self.containerWidth = self.frame.size.width;
//    [super layoutSubviews];
//    [self invalidateIntrinsicContentSize];
//}

- (CGSize)sizeForWidth:(CGFloat)width
{
    return CGSizeMake(width, kMinimumTitleViewHeight);
}

//- (CGSize)intrinsicContentSize
//{
//    return CGSizeMake(self.containerWidth, kMinimumTitleViewHeight);
//}

@end
