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
    titleView.number = self.song.number;
    titleView.title = self.song.title;
    
    return titleView;
}

- (NSAttributedString *)text
{
    SongTitleView *titleView = (SongTitleView *)self.titleView;
    
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:20];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:30];
    numberAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:0
                                                                          andNormalIndent:titleView.titleOriginX];

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:22];
    titleAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:0
                                                                         andNormalIndent:titleView.titleOriginX];

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *subtitleAttributes = [normalAttributes mutableCopy];
    subtitleAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:titleView.titleOriginX
                                                                            andNormalIndent:titleView.titleOriginX];
    subtitleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:15];
    
    NSMutableDictionary *verseTitleAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *verseTitleParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    verseTitleParagraphStyle.alignment = NSTextAlignmentCenter;
    verseTitleAttributes[NSParagraphStyleAttributeName] = verseTitleParagraphStyle;
    
    NSMutableDictionary *chorusAttributes = [normalAttributes mutableCopy];
    chorusAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:20 andNormalIndent:0];
    
    NSMutableDictionary *ghostChorusAttributes = [chorusAttributes mutableCopy];
    [ghostChorusAttributes addEntriesFromDictionary:ghostAttributes];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (self.song.number) {
        [attributedString appendString:[self.song.number stringValue] attributes:numberAttributes];
        [attributedString appendString:@" " attributes:titleAttributes];
    }
    
    if ([self.song.title length] > 0) {
        [attributedString appendString:self.song.title attributes:titleAttributes];
        [attributedString appendString:@"\n" attributes:normalAttributes];
    }
    
    if ([self.song.subtitle length] > 0) {
        [attributedString appendString:self.song.subtitle attributes:subtitleAttributes];
        [attributedString appendString:@"\n\n" attributes:normalAttributes];
    } else {
        [attributedString appendString:@"\n" attributes:normalAttributes];
    }
    
    [self.song.verses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Verse *verse = (Verse *)obj;
        
        if (idx != 0) {
            [attributedString appendString:@"\n\n" attributes:normalAttributes];
        }
        
        if (verse.title) {
            [attributedString appendString:[NSString stringWithFormat:@"%@\n", verse.title] attributes:verseTitleAttributes];
        }
        if ([verse.isChorus boolValue]) {
            [attributedString appendString:[NSString stringWithFormat:@"Chorus: %@", verse.text] attributes:chorusAttributes];
        } else {
            if (verse.number) {
                [attributedString appendString:[NSString stringWithFormat:@"%@. ", verse.number] attributes:normalAttributes];
            }
            [attributedString appendString:verse.text attributes:normalAttributes];

            if (verse.chorus) {
                [attributedString appendString:@"\n\n" attributes:normalAttributes];
                [attributedString appendString:[NSString stringWithFormat:@"Chorus: %@", verse.chorus.text] attributes:ghostChorusAttributes];
            }
        }
    }];
    
    [attributedString appendString:@"\n" attributes:normalAttributes];
    
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
