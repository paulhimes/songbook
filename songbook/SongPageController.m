//
//  SongPageController.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongPageController.h"
#import "Verse.h"
#import "SongTitleView.h"

static const NSInteger kGutterWidth = 8;

@interface SongPageController ()

@property (strong, nonatomic) Song *song;

@end

@implementation SongPageController

- (instancetype)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        self.song = song;
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.song;
}

- (TitleView *)buildTitleView
{
    SongTitleView *titleView = [[SongTitleView alloc] init];
    titleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.98];
    titleView.number = self.song.number;
    titleView.title = self.song.title;
    
    return titleView;
}

- (NSAttributedString *)text
{
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:20];

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *subtitleAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    SongTitleView *titleView = (SongTitleView *)self.titleView;
    paragraphStyle.firstLineHeadIndent = titleView.titleOriginX - kGutterWidth;
    paragraphStyle.headIndent = paragraphStyle.firstLineHeadIndent;
    subtitleAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if ([self.song.subtitle length] > 0) {
        [attributedString appendString:self.song.subtitle attributes:subtitleAttributes];
        [attributedString appendString:@"\n\n" attributes:normalAttributes];
    }
    
    [self.song.verses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Verse *verse = (Verse *)obj;
        
        if (idx != 0) {
            [attributedString appendString:@"\n\n" attributes:normalAttributes];
        }
        
        if (verse.title) {
            [attributedString appendString:[NSString stringWithFormat:@"\t\t\t%@\n", verse.title] attributes:normalAttributes];
        }
        if ([verse.isChorus boolValue]) {
            [attributedString appendString:[NSString stringWithFormat:@"Chorus: %@", verse.text] attributes:normalAttributes];
        } else {
            if (verse.number) {
                [attributedString appendString:[NSString stringWithFormat:@"%@. ", verse.number] attributes:normalAttributes];
            }
            [attributedString appendString:verse.text attributes:normalAttributes];

            if (verse.chorus) {
                [attributedString appendString:@"\n\n" attributes:normalAttributes];
                [attributedString appendString:[NSString stringWithFormat:@"Chorus: %@", verse.chorus.text] attributes:ghostAttributes];
            }
        }
    }];

    return [attributedString copy];
}



- (NSAttributedString *)titleString
{
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    
    CGFloat fontSize = 30;
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineHeightMultiple = 1.3;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableDictionary *attributes = [@{
                                         NSFontAttributeName: [UIFont fontWithName:@"Marion" size:fontSize],
                                         NSParagraphStyleAttributeName: paragraphStyle
                                         } mutableCopy];
    
    NSMutableDictionary *numberAttributes = [attributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:fontSize];
    
    if (self.song.number) {
        NSString *numberString = [NSString stringWithFormat:@"%d", [self.song.number unsignedIntegerValue]];
        attributedTitle = [[NSMutableAttributedString alloc] initWithString:numberString
                                                                 attributes:numberAttributes];
    }
    
    return [attributedTitle copy];
}

@end
