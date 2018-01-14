//
//  SongTitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongTitleView.h"

const CGFloat kMinimumTitleViewHeight = 44;
const CGFloat kTitleNumberFontSize = 30;
const CGFloat kTitleFontSize = 22;
const CGFloat kSubtitleFontSize = 15;

static const NSInteger kTopMargin = 16;
static const CGFloat kSongComponentPadding = 8;

@interface SongTitleView()

@property (nonatomic, strong) UIFont *numberFont;
@property (nonatomic, strong) NSDictionary *numberAttributes;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSDictionary *titleAttributes;

@end

@implementation SongTitleView

- (UIFont *)numberFont
{
    if (!_numberFont) {
        _numberFont = [UIFont fontWithName:@"Marion-Bold" size:kTitleNumberFontSize];
    }
    return _numberFont;
}

- (NSDictionary *)numberAttributes
{
    if (!_numberAttributes) {
        _numberAttributes = @{NSFontAttributeName: self.numberFont, NSForegroundColorAttributeName: [Theme textColor]};
    }
    return _numberAttributes;
}

- (UIFont *)titleFont
{
    if (!_titleFont) {
        _titleFont = [UIFont fontWithName:@"Marion" size:kTitleFontSize];
    }
    return _titleFont;
}

- (NSDictionary *)titleAttributes
{
    if (!_titleAttributes) {
        _titleAttributes = @{NSFontAttributeName: self.titleFont, NSForegroundColorAttributeName: [Theme textColor]};
    }
    return _titleAttributes;
}

- (CGFloat)titleOriginX
{
    NSAttributedString *numberText = [self numberText];
    CGRect numberRect = [numberText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.numberFont.lineHeight)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                 context:nil];
    
    CGFloat titleOriginX = numberRect.size.width;
    return titleOriginX;
}

- (CGFloat)contentOriginY
{
    CGRect textRect = [self placedTextRectForWidth:self.bounds.size.width];
    return textRect.origin.y;
}

- (CGSize)sizeForWidth:(CGFloat)width
{
    CGRect textRect = [self placedTextRectForWidth:width];
    CGFloat titleLowestBaseline = CGRectGetMaxY(textRect) + self.titleFont.descender;
    CGSize size = CGSizeMake(width, titleLowestBaseline + kSongComponentPadding);
    return size;
}

- (CGSize)intrinsicContentSize
{
    return [self sizeForWidth:self.bounds.size.width];
}

- (CGRect)textRectForWidth:(CGFloat)width
{
    CGRect boundingRect = [[self text] boundingRectWithSize:CGSizeMake(width, self.numberFont.lineHeight)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    context:nil];
    return boundingRect;
}

- (CGRect)placedTextRectForWidth:(CGFloat)width
{
    CGRect textRect = [self textRectForWidth:width];
    CGFloat titleLowestBaseline = CGRectGetMaxY(textRect) + self.titleFont.descender;
    CGFloat proposedBottom = kTopMargin + titleLowestBaseline + kSongComponentPadding;
    CGFloat additionalTopMargin = MAX(kMinimumTitleViewHeight - proposedBottom, 0);
    
    CGRect placedRect = CGRectMake(0, additionalTopMargin + kTopMargin, textRect.size.width, textRect.size.height);
    return placedRect;
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawingRect = [self placedTextRectForWidth:self.bounds.size.width];
    [[self text] drawWithRect:drawingRect options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine context:nil];
}

- (NSAttributedString *)numberText
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (self.number) {
        [attributedString appendString:[self.number stringValue] attributes:self.numberAttributes];
        [attributedString appendString:@" " attributes:self.titleAttributes];
    }
    
    return [attributedString copy];
}

- (NSAttributedString *)text
{
    NSMutableAttributedString *attributedString = [[self numberText] mutableCopy];
    
    if ([self.title length] > 0) {
        [attributedString appendString:self.title attributes:self.titleAttributes];
    }
    
    [attributedString addAttributes:@{NSParagraphStyleAttributeName: [self paragraphStyleFirstLineIndent:0 andNormalIndent:self.titleOriginX]}
                              range:NSMakeRange(0, attributedString.length)];
    
    return [attributedString copy];
}

- (NSParagraphStyle *)paragraphStyleFirstLineIndent:(CGFloat)firstLineIndent
                                    andNormalIndent:(CGFloat)normalIndent
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.firstLineHeadIndent = firstLineIndent;
    paragraphStyle.headIndent = normalIndent;
    return paragraphStyle;
}

@end
