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

@interface SongPageController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) NSArray *relatedSongs;

@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet SongTitleView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) UITableView *relatedItemsView;

@end

@implementation SongPageController

- (void)setSong:(Song *)song
{
    _song = song;
    
    self.relatedSongs = [self.song.relatedSongs allObjects];
}

- (void)viewDidLoad
{
    [self.relatedItemsView setHeight:self.relatedItemsView.contentHeight];
    [self.textView addSubview:self.relatedItemsView];
    
    self.titleView.number = self.song.number;
    self.titleView.title = self.song.title;
    
    CGFloat titleContentOriginY = self.titleView.contentOriginY;
    //    NSLog(@"titleContentOriginY %f", titleContentOriginY);
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 0, 0);
    
    self.topBar.delegate = self;
    self.bottomBar.delegate = self;

    UIImage *searchButtonImage = [[self.searchButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *searchButtonHighlightedImage = [[self.searchButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setImage:searchButtonImage forState:UIControlStateNormal];
    [self.searchButton setImage:searchButtonHighlightedImage forState:UIControlStateHighlighted];

    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.titleView setNeedsDisplay];
}

- (NSManagedObject *)modelObject
{
    return self.song;
}

- (UITableView *)relatedItemsView
{
    if (!_relatedItemsView) {
        _relatedItemsView = [[UITableView alloc] init];
        _relatedItemsView.dataSource = self;
        _relatedItemsView.delegate = self;
        _relatedItemsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _relatedItemsView.scrollEnabled = NO;
        _relatedItemsView.separatorInset = UIEdgeInsetsZero;
        _relatedItemsView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_relatedItemsView setDebugColor:[UIColor purpleColor]];
    }
    return _relatedItemsView;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    SongTitleView *titleView = (SongTitleView *)self.titleView;
    
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:standardTextSize];
    
    NSParagraphStyle *numberAndTitleParagraphStyle = [self paragraphStyleFirstLineIndent:0
                                                                         andNormalIndent:titleView.titleOriginX];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:kTitleNumberFontSize];
    numberAttributes[NSParagraphStyleAttributeName] = numberAndTitleParagraphStyle;

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kTitleFontSize];
    titleAttributes[NSParagraphStyleAttributeName] = numberAndTitleParagraphStyle;

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
    
    for (NSUInteger verseIndex = 0; verseIndex < [self.song.verses count]; verseIndex++) {
        Verse *verse = self.song.verses[verseIndex];
        
        if (verseIndex != 0) {
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
    }
    
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

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        self.topBar.hidden = YES;
        self.titleView.hidden = YES;
        self.textView.showsVerticalScrollIndicator = NO;
    } else {
        self.topBar.hidden = NO;
        self.titleView.hidden = NO;
        self.textView.showsVerticalScrollIndicator = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (ABS(targetContentOffset->y) <= 1) {
        targetContentOffset->y = 0;
    }
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if (bar == self.topBar) {
        return UIBarPositionBottom;
    } else if (bar == self.bottomBar) {
        return UIBarPositionTop;
    }
    return UIBarPositionAny;
}

@end
