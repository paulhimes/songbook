//
//  PageView.h
//  songbook
//
//  Created by Paul Himes on 7/31/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageView : UIView

@property (nonatomic, readonly) CGFloat headerHeight;
@property (nonatomic) CGSize containerSize;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) UIFont *font;

@end
