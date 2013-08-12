//
//  SongPageView.m
//  songbook
//
//  Created by Paul Himes on 8/1/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongPageView.h"
#import "Verse.h"

const CGFloat kSongComponentPadding = 10;
const CGFloat kTopPadding = 44;

@interface SongPageView()

@property (nonatomic, strong) Song *song;

@property (nonatomic, strong) UIFont *songNumberFont;
@property (nonatomic, strong) UIFont *songTitleFont;
@property (nonatomic, strong) UIFont *songSubtitleFont;
@property (nonatomic, strong) UIFont *verseFont;
@property (nonatomic, strong) NSString *fontName;

@property (nonatomic) CGRect songNumberRect;
@property (nonatomic) CGRect songTitleRect;
@property (nonatomic) CGRect songSubtitleRect;

@property (nonatomic, strong) UITextView *bodyTextView;

@end

@implementation SongPageView

- (NSString *)fontName
{
    return @"Marion";
}

- (UIFont *)songNumberFont
{
    if (!_songNumberFont) {
        _songNumberFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.fontName] size:30];
    }
    return _songNumberFont;
}

- (UIFont *)songTitleFont
{
    if (!_songTitleFont) {
        _songTitleFont = [UIFont fontWithName:self.fontName size:22];
    }
    return _songTitleFont;
}

- (UIFont *)songSubtitleFont
{
    if (!_songSubtitleFont) {
        _songSubtitleFont = [UIFont fontWithName:self.fontName size:20];
    }
    return _songSubtitleFont;
}

- (UIFont *)verseFont
{
    if (!_verseFont) {
        _verseFont = [UIFont fontWithName:self.fontName size:20];
    }
    return _verseFont;
}

- (CGRect)songNumberRect
{
    if (CGRectIsEmpty(_songNumberRect)) {
        CGRect boundingRect = [[self.song.number stringValue] boundingRectWithSize:CGSizeMake(self.containerSize.width, CGFLOAT_MAX)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName: self.songNumberFont}
                                                                           context:nil];
        _songNumberRect = CGRectMake(0, kTopPadding + kSongComponentPadding, boundingRect.size.width, boundingRect.size.height);
    }
    return _songNumberRect;
}

- (CGRect)songTitleRect
{
    if (CGRectIsEmpty(_songTitleRect)) {
        CGFloat availableWidth;
        CGPoint origin;
        BOOL attemptToCenterVertically = NO;
        if (self.songNumberRect.size.width + kSongComponentPadding > (self.containerSize.width - self.containerSize.width / M_PHI)) {
            availableWidth = self.containerSize.width;
            origin = CGPointMake(0, self.songNumberRect.size.height + kSongComponentPadding);
        } else {
            CGFloat leftMargin = self.songNumberRect.size.width > 0 ? CGRectGetMaxX(self.songNumberRect) + kSongComponentPadding : 0;
            
            availableWidth = self.containerSize.width - leftMargin;
            origin = CGPointMake(leftMargin, self.songNumberRect.origin.y);
            attemptToCenterVertically = YES;
        }
        
        CGRect boundingRect = [self.song.title boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: self.songTitleFont}
                                                            context:nil];
        
        if (attemptToCenterVertically) {
            // Attempt to center the title vertically with the number.
            if (boundingRect.size.height < self.songNumberRect.size.height) {
                origin.y = self.songNumberRect.origin.y + (self.songNumberRect.size.height - boundingRect.size.height) / 2.0;
            }
        }
        
        _songTitleRect = CGRectMake(origin.x, origin.y, boundingRect.size.width, boundingRect.size.height);
        
        NSLog(@"songTitleRect = %@ for %@", NSStringFromCGRect(_songTitleRect), self.song.title);
    }
    return _songTitleRect;
}

- (CGRect)songSubtitleRect
{
    if (CGRectIsEmpty(_songSubtitleRect)) {
        CGRect boundingRect = [self.song.subtitle boundingRectWithSize:CGSizeMake(self.containerSize.width - self.songTitleRect.origin.x, CGFLOAT_MAX)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName: self.songSubtitleFont}
                                                                           context:nil];
        
        // Shift the title back up to the top of the number if possible and the subtitle needs the room.
        if (self.songTitleRect.origin.x > 0 && self.songTitleRect.size.height + boundingRect.size.height > self.songNumberRect.size.height) {
            self.songTitleRect = CGRectMake(self.songTitleRect.origin.x, self.songNumberRect.origin.y, self.songTitleRect.size.width, self.songTitleRect.size.height);
        }
        
        _songSubtitleRect = CGRectMake(self.songTitleRect.origin.x, CGRectGetMaxY(self.songTitleRect), boundingRect.size.width, boundingRect.size.height);
    }
    return _songSubtitleRect;
}

- (UITextView *)bodyTextView
{
    if (!_bodyTextView) {
        _bodyTextView = [[UITextView alloc] init];
        _bodyTextView.scrollEnabled = NO;
        _bodyTextView.editable = NO;
        _bodyTextView.attributedText = [self bodyStringFromSong:self.song];
        _bodyTextView.textContainer.lineFragmentPadding = 0;
        _bodyTextView.textContainerInset = UIEdgeInsetsZero;
        CGSize size = [_bodyTextView sizeThatFits:CGSizeMake(self.containerSize.width, CGFLOAT_MAX)];
        CGRect headerRect = CGRectUnion(CGRectUnion(self.songNumberRect, self.songTitleRect), self.songSubtitleRect);
        
        _bodyTextView.frame = CGRectMake(0, CGRectGetMaxY(headerRect) + kSongComponentPadding, size.width, size.height);
        [_bodyTextView setDebugColor:[UIColor purpleColor]];
        
        [self addSubview:_bodyTextView];
        
        UITextView *bodyTextView = _bodyTextView;
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(bodyTextView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bodyTextView]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[bodyTextView(%f)]|", CGRectGetMaxY(headerRect) + kSongComponentPadding, size.height] options:0 metrics:nil views:viewsDictionary]];
    }
    return _bodyTextView;
}

- (void)resetRectangleCalculations
{
    self.songNumberRect = CGRectZero;
    self.songTitleRect = CGRectZero;
    self.songSubtitleRect = CGRectZero;
    [self.bodyTextView removeFromSuperview];
    self.bodyTextView = nil;
}

- (instancetype)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        self.song = song;
    }
    return self;
}

- (CGFloat)headerHeight
{
    return self.songNumberRect.size.height / 2.0;
}

- (void)setContainerSize:(CGSize)containerSize
{
    [self resetRectangleCalculations];
    [super setContainerSize:containerSize];
}

- (CGSize)intrinsicContentSize
{
    CGRect totalContentRect = CGRectUnion(CGRectUnion(CGRectUnion(self.songNumberRect, self.songTitleRect), self.songSubtitleRect), self.bodyTextView.frame);
    return CGSizeMake(self.containerSize.width, totalContentRect.size.height + kTopPadding + kSongComponentPadding);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];

    [[self.song.number stringValue] drawWithRect:self.songNumberRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.songNumberFont} context:nil];
    [self.song.title drawWithRect:self.songTitleRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.songTitleFont} context:nil];
    [self.song.subtitle drawWithRect:self.songSubtitleRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.songSubtitleFont} context:nil];
}

- (NSAttributedString *)bodyStringFromSong:(Song *)song
{
    NSMutableString *string = [@"" mutableCopy];

    [song.verses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Verse *verse = (Verse *)obj;
        
        if (idx != 0) {
            [string appendString:@"\n\n"];
        }
        
        if (verse.title) {
            [string appendFormat:@"\t\t\t%@\n", verse.title];
        }
        if ([verse.isChorus boolValue]) {
            [string appendFormat:@"Chorus: %@", verse.text];
        } else {
            if (verse.number) {
                [string appendFormat:@"%@. ", verse.number];
            }
            [string appendString:verse.text];
            if (verse.chorus) {
                [string appendString:@"\n\n"];
                [string appendFormat:@"Chorus: %@", verse.chorus.text];
            }
        }
    }];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: self.verseFont,
                                 };
    
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

@end
