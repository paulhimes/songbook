//
//  TitleView.h
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kMinimumTitleViewHeight;

@interface TitleView : UIView

@property (nonatomic, readonly) CGFloat contentOriginY;

- (CGSize)sizeForWidth:(CGFloat)width;
- (void)resetMetrics;


@end
