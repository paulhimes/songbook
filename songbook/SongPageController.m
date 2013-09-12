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
@property (nonatomic, strong) NSArray *relatedSongs;

@end

@implementation SongPageController

- (instancetype)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        self.song = song;
        self.relatedSongs = [self.song.relatedSongs allObjects];
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
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    SongTitleView *titleView = (SongTitleView *)self.titleView;
    
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:standardTextSize];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:kTitleNumberFontSize];
    numberAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:0
                                                                          andNormalIndent:titleView.titleOriginX];

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kTitleFontSize];
    titleAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:0
                                                                         andNormalIndent:titleView.titleOriginX];

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *subtitleAttributes = [normalAttributes mutableCopy];
    subtitleAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:titleView.titleOriginX
                                                                            andNormalIndent:titleView.titleOriginX];
    subtitleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kSubtitleFontSize];
    
    NSMutableDictionary *verseTitleAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *verseTitleParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    verseTitleParagraphStyle.alignment = NSTextAlignmentCenter;
    verseTitleAttributes[NSParagraphStyleAttributeName] = verseTitleParagraphStyle;
    
    NSMutableDictionary *chorusAttributes = [normalAttributes mutableCopy];
    chorusAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:standardTextSize andNormalIndent:0];
    
    NSMutableDictionary *ghostChorusAttributes = [chorusAttributes mutableCopy];
    [ghostChorusAttributes addEntriesFromDictionary:ghostAttributes];
    
    NSMutableDictionary *footerAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *footerParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    footerParagraphStyle.alignment = NSTextAlignmentRight;
    footerAttributes[NSParagraphStyleAttributeName] = footerParagraphStyle;
    
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
            
            if (verse.repeatText) {
                [attributedString appendString:@" " attributes:ghostAttributes];
                [attributedString appendString:verse.repeatText attributes:ghostAttributes];
            }

            if (verse.chorus) {
                [attributedString appendString:@"\n\n" attributes:normalAttributes];
                [attributedString appendString:[NSString stringWithFormat:@"Chorus: %@", verse.chorus.text] attributes:ghostChorusAttributes];
            }
        }
    }];
    
    if ([self.song.author length] > 0 ||
        [self.song.year length] > 0) {
        [attributedString appendString:@"\n\n" attributes:normalAttributes];
    }
    
    if ([self.song.author length] > 0) {
        [attributedString appendString:self.song.author attributes:footerAttributes];
    }
    
    if ([self.song.year length] > 0) {
        if ([self.song.author length] > 0) {
            [attributedString appendString:@" " attributes:footerAttributes];
        }
        [attributedString appendString:self.song.year attributes:footerAttributes];
    }
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.relatedSongs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    Song *relatedSong = self.relatedSongs[indexPath.row];
    
    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                         attributes:nil];
    if (relatedSong.number) {
        [attributedString appendString:[NSString stringWithFormat:@"%d", [relatedSong.number integerValue]]attributes:numberAttributes];
        [attributedString appendString:@" " attributes:titleAttributes];
    }
    
    [attributedString appendString:relatedSong.title attributes:titleAttributes];
    
    cell.textLabel.attributedText = attributedString;

    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.relatedSongs count] > 0 ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Related Songs";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate pageController:self selectedModelObject:self.relatedSongs[indexPath.row]];
}

@end
