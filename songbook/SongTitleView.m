//
//  SongTitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongTitleView.h"
#import "PageController.h"

const CGFloat kTitleNumberFontSize = 30;
const CGFloat kTitleFontSize = 22;
const CGFloat kSubtitleFontSize = 15;

static const NSInteger kTopMargin = 16;
static const CGFloat kSongComponentPadding = 8;

@interface SongTitleView()

@property (nonatomic, strong) UIFont *numberFont;
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
        _titleAttributes = @{NSFontAttributeName: self.titleFont};
    }
    return _titleAttributes;
}

- (CGFloat)titleOriginX
{
    NSAttributedString *numberText = [self numberText];
    CGRect numberRect = [numberText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.numberFont.lineHeight)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                 context:nil];
    return numberRect.size.width;
}

- (CGFloat)contentOriginY
{
    CGRect textRect = [self placedTextRectForWidth:self.bounds.size.width];
    return textRect.origin.y;
}

- (CGSize)sizeForWidth:(CGFloat)width
{
//    NSLog(@"sizeForWidth for %@ %f", self.title, width);
    
    CGRect textRect = [self placedTextRectForWidth:width];
    CGFloat titleLowestBaseline = CGRectGetMaxY(textRect) + self.titleFont.descender;
    CGSize size = CGSizeMake(width, titleLowestBaseline + kSongComponentPadding);
    
//    NSLog(@"final %@ size %@", self.title, NSStringFromCGSize(size));
    
    return size;
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
//    NSLog(@"content width for %@ %f", self.title, width);
    
    CGRect textRect = [self textRectForWidth:width];
    CGFloat titleLowestBaseline = CGRectGetMaxY(textRect) + self.titleFont.descender;
    CGFloat proposedBottom = kTopMargin + titleLowestBaseline + kSongComponentPadding;
    CGFloat additionalTopMargin = MAX(kMinimumTitleViewHeight - proposedBottom, 0);
    
//    NSLog(@"original rect for %@ %@", self.title, NSStringFromCGRect(textRect));
    
//    NSLog(@"additional top margin for %@ %f", self.title, additionalTopMargin);

    
    CGRect placedRect = CGRectMake(0, additionalTopMargin + kTopMargin, textRect.size.width, textRect.size.height);
    return placedRect;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];
    
//    NSLog(@"bounds width for %@ %f", self.title, self.bounds.size.width);

    
    CGRect drawingRect = [self placedTextRectForWidth:self.bounds.size.width];
//    NSLog(@"drawing rect for %@ %@", self.title, NSStringFromCGRect(drawingRect));
    [[self text] drawWithRect:drawingRect options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine context:nil];
    
//    [[UIColor colorWithWhite:0 alpha:0.5] setStroke];
//    [[UIBezierPath bezierPathWithRect:drawingRect] stroke];
}

- (NSAttributedString *)numberText
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (self.number) {
        [attributedString appendString:[self.number stringValue] attributes:@{NSFontAttributeName: self.numberFont}];
        [attributedString appendString:@" " attributes:@{NSFontAttributeName: self.titleFont}];
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
    
    
//    NSLog(@"%@", attributedString);
    
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

- (void)resetMetrics
{
    self.numberFont = nil;
    self.titleFont = nil;
    self.titleAttributes = nil;
}

- (void)setNeedsDisplay
{
    [self resetMetrics];
    [super setNeedsDisplay];
}

- (void)setNeedsLayout
{
    [self resetMetrics];
    [super setNeedsLayout];
}

@end
