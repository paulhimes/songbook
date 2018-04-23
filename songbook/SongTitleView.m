//
//  SongTitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongTitleView.h"
#import "songbook-Swift.h"

const CGFloat kTitleNumberFontSize = 36;
const CGFloat kTitleFontSize = 24;
const CGFloat kSubtitleFontSize = 15;

static const NSInteger kTopMargin = 0;
static const CGFloat kSongComponentPadding = 8;

@interface SongTitleView()

@property (nonatomic, readonly) UIFont *numberFont;
@property (nonatomic, readonly) NSDictionary *numberAttributes;
@property (nonatomic, readonly) UIFont *titleFont;
@property (nonatomic, readonly) NSDictionary *titleAttributes;

@end

@implementation SongTitleView

- (UIFont *)numberFont
{
    return [UIFont fontWithDynamicName:[Theme titleNumberFontName] size:kTitleNumberFontSize numberSpacing:NumberSpacingProportional];
}

- (NSDictionary *)numberAttributes
{
    return @{NSFontAttributeName: self.numberFont, NSForegroundColorAttributeName: [Theme textColor]};
}

- (UIFont *)titleFont
{
    return [UIFont fontWithDynamicName:[Theme normalFontName] size:kTitleFontSize];
}

- (NSDictionary *)titleAttributes
{
    return @{NSFontAttributeName: self.titleFont, NSForegroundColorAttributeName: [Theme textColor]};
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
    CGRect boundingRect = [[self textForWidth:width] boundingRectWithSize:CGSizeMake(width, self.numberFont.lineHeight)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                  context:nil];
    return boundingRect;
}

- (CGRect)placedTextRectForWidth:(CGFloat)width
{
    CGRect textRect = [self textRectForWidth:width];
    CGRect placedRect = CGRectMake(0, kTopMargin, textRect.size.width, textRect.size.height);
    return placedRect;
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawingRect = [self placedTextRectForWidth:self.bounds.size.width];
    [[self textForWidth:self.bounds.size.width] drawWithRect:drawingRect options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine context:nil];
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

- (NSAttributedString *)textForWidth:(CGFloat)width
{
    NSMutableAttributedString *attributedString = nil;

    CGRect boundingRect = CGRectMake(0, 0, CGFLOAT_MAX, 0);
    NSString *fittedTitle = self.title;

    do {
        attributedString = [[self numberText] mutableCopy];

        if ([fittedTitle length] > 0) {
            [attributedString appendString:fittedTitle attributes:self.titleAttributes];
        } else {
            break;
        }

        [attributedString addAttributes:@{NSParagraphStyleAttributeName: [self paragraphStyleFirstLineIndent:0 andNormalIndent:self.titleOriginX]}
                                  range:NSMakeRange(0, attributedString.length)];

        boundingRect = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.numberFont.lineHeight)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil];
        if (boundingRect.size.width >= width) {
            // Truncate the fitted title one word at a time.
            NSMutableArray<NSString *> *components = [[fittedTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
            [components removeLastObject];
            NSString *joined = [components componentsJoinedByString:@" "];
            fittedTitle = [joined stringByAppendingString:@"…"];
        }
    } while (boundingRect.size.width >= width);

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
