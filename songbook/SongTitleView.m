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
        CGRect boundingRect = [[self.number stringValue] boundingRectWithSize:CGSizeMake(self.containerWidth, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName: self.numberFont}
                                                                      context:nil];
        _numberRect = CGRectMake(0, kTopMargin, boundingRect.size.width, boundingRect.size.height);
    }
    return _numberRect;
}

- (CGRect)titleRect
{
    if (CGRectIsEmpty(_titleRect)) {
        CGFloat availableWidth;
        CGPoint origin;
        BOOL attemptToAlignVertically = NO;
        if (self.numberRect.size.width + kSongComponentPadding > (self.containerWidth - self.containerWidth / M_PHI)) {
            availableWidth = self.containerWidth;
            CGFloat numberBaseLine = CGRectGetMaxY(self.numberRect) + self.numberFont.descender;

            origin = CGPointMake(0, numberBaseLine + kSongComponentPadding);
        } else {
            CGFloat leftMargin = self.numberRect.size.width > 0 ? CGRectGetMaxX(self.numberRect) + kSongComponentPadding : 0;
            
            availableWidth = self.containerWidth - leftMargin;
            origin = CGPointMake(leftMargin, self.numberRect.origin.y);
            attemptToAlignVertically = YES;
        }
        
        CGRect boundingRect = [self.title boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: self.titleFont}
                                                            context:nil];
        
        if (attemptToAlignVertically) {
            CGFloat numberBaseLine = CGRectGetMaxY(self.numberRect) + self.numberFont.descender;
            CGFloat titleHeightMinusDescender = boundingRect.size.height + self.titleFont.descender;
            
            origin.y = numberBaseLine - titleHeightMinusDescender;
            
            if (origin.y < self.numberRect.origin.y) {
                origin.y = self.numberRect.origin.y;
            }
        }
        
        _titleRect = CGRectMake(origin.x, origin.y, boundingRect.size.width, boundingRect.size.height);
    }
    return _titleRect;
}

- (CGFloat)titleOriginX
{
    CGRect titleRect = self.titleRect;
    return titleRect.origin.x;
}

- (void)resetRectangleCalculations
{
    self.numberRect = CGRectZero;
    self.titleRect = CGRectZero;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)intrinsicContentSize
{    
    CGFloat titleLowestBaseline = CGRectGetMaxY(self.titleRect) + self.titleFont.descender;
    
    return CGSizeMake(self.containerWidth, titleLowestBaseline + kSongComponentPadding);
}

- (void)drawRect:(CGRect)rect
{
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
