//
//  SongTitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongTitleView.h"

static const NSInteger kTopMargin = 16;
static const CGFloat kSongComponentPadding = 8;

@interface SongTitleView()

@property (nonatomic, strong) UIFont *numberFont;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic) CGRect numberRect;
@property (nonatomic) CGRect titleRect;

@end

@implementation SongTitleView

- (NSString *)fontName
{
    return @"Marion";
}

- (UIFont *)numberFont
{
    if (!_numberFont) {
        _numberFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.fontName] size:30];
    }
    return _numberFont;
}

- (UIFont *)titleFont
{
    if (!_titleFont) {
        _titleFont = [UIFont fontWithName:self.fontName size:22];
    }
    return _titleFont;
}

- (CGRect)numberRect
{
    if (CGRectIsEmpty(_numberRect)) {
        _numberRect = CGRectZero;
    }
    return _numberRect;
}

- (CGRect)titleRect
{
    if (CGRectIsEmpty(_titleRect)) {
        _titleRect = CGRectZero;
    }
    return _titleRect;
}

- (CGFloat)titleOriginX
{
    CGRect titleRect = self.titleRect;
    return titleRect.origin.x;
}

- (CGSize)sizeForWidth:(CGFloat)width
{
    [self calculateRectsForWidth:width];
    CGFloat titleLowestBaseline = CGRectGetMaxY(self.titleRect) + self.titleFont.descender;
//    NSLog(@"%f", titleLowestBaseline);
    
    return CGSizeMake(width, titleLowestBaseline + kSongComponentPadding);
}

- (void)calculateRectsForWidth:(CGFloat)width
{
    self.numberRect = [self numberRectForWidth:width];
    self.titleRect = [self titleRectForWidth:width andNumberRect:self.numberRect];
    
    // Validate that the total header height will be at least kMinimumTitleViewHeight
    CGFloat titleLowestBaseline = CGRectGetMaxY(self.titleRect) + self.titleFont.descender;
    CGFloat titleBaselineWithPadding = titleLowestBaseline + kSongComponentPadding;
    if (titleBaselineWithPadding < kMinimumTitleViewHeight) {
        CGFloat verticalAdjustment = kMinimumTitleViewHeight - titleBaselineWithPadding;
        
        self.titleRect = CGRectMake(self.titleRect.origin.x,
                                    self.titleRect.origin.y + verticalAdjustment,
                                    self.titleRect.size.width,
                                    self.titleRect.size.height);
        
        self.numberRect = CGRectMake(self.numberRect.origin.x,
                                     self.numberRect.origin.y + verticalAdjustment,
                                     self.numberRect.size.width,
                                     self.numberRect.size.height);
    }
}

- (CGRect)numberRectForWidth:(CGFloat)width
{
    CGRect boundingRect = [[self.number stringValue] boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName: self.numberFont}
                                                                  context:nil];
    return CGRectMake(0, kTopMargin, boundingRect.size.width, boundingRect.size.height);
}

- (CGRect)titleRectForWidth:(CGFloat)width andNumberRect:(CGRect)numberRect
{
    CGFloat leftMargin = numberRect.size.width > 0 ? CGRectGetMaxX(numberRect) + kSongComponentPadding : 0;
    
    CGRect boundingRect = [self.title boundingRectWithSize:CGSizeMake(width - leftMargin, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName: self.titleFont}
                                                   context:nil];
    
    CGFloat numberBaseLine = CGRectGetMaxY(numberRect) + self.numberFont.descender;
    CGFloat titleHeightMinusDescender = boundingRect.size.height + self.titleFont.descender;
    
    CGPoint origin = CGPointMake(leftMargin, numberBaseLine - titleHeightMinusDescender);
    if (origin.y < numberRect.origin.y) {
        origin.y = numberRect.origin.y;
    }
    
    return CGRectMake(origin.x, origin.y, boundingRect.size.width, boundingRect.size.height);
}

- (void)drawRect:(CGRect)rect
{
    [self calculateRectsForWidth:self.bounds.size.width];
    
    // Drawing code
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];

    [[self.number stringValue] drawWithRect:self.numberRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.numberFont} context:nil];
    [self.title drawWithRect:self.titleRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleFont} context:nil];
    
//    [[UIColor colorWithWhite:0 alpha:0.5] setStroke];
//    CGFloat numberBaseLine = CGRectGetMaxY(self.numberRect) + self.numberFont.descender;
//    [[UIBezierPath bezierPathWithRect:CGRectMake(self.numberRect.origin.x, self.numberRect.origin.y, self.numberRect.size.width, numberBaseLine - self.numberRect.origin.y)] stroke];
//    CGFloat titleBaseLine = CGRectGetMaxY(self.titleRect) + self.titleFont.descender;
//    [[UIBezierPath bezierPathWithRect:CGRectMake(self.titleRect.origin.x, self.titleRect.origin.y, self.titleRect.size.width, titleBaseLine - self.titleRect.origin.y)] stroke];
}

@end
