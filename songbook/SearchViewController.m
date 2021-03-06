//
//  SearchViewController.m
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//

#import "SearchViewController.h"
#import "Section.h"
#import "Song.h"
#import "SmartSearcher.h"
#import "SearchOperation.h"
#import "SearchTableDataSource.h"
#import "TokenizeOperation.h"
#import "SuperScrollIndicator.h"
#import "songbook-Swift.h"

static NSString * const kPreferredSearchMethodKey = @"PreferredSearchMethodKey";
static NSString * const kSearchTimestampKey = @"SearchTimestampKey";

typedef enum PreferredSearchMethod : NSUInteger {
    PreferredSearchMethodNumbers,
    PreferredSearchMethodLetters
} PreferredSearchMethod;

@interface SearchViewController () <UITableViewDelegate, SearchTableDataSourceDelegate, SuperScrollIndicatorDelegate, UISearchBarDelegate>

@property (nonatomic, strong) SearchTableDataSource *dataSource;
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *lastSearchString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *topBarEffectView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, readonly) UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenTextField;

@property (weak, nonatomic) IBOutlet SuperScrollIndicator *scrollIndicator;

@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIProgressView *tokenizeProgressView;
@property (nonatomic) NSUInteger latestTokenizePercentComplete;
@property (nonatomic, strong) id observerToken;

@property (nonatomic, readonly) Song *closestSong;

@end

@implementation SearchViewController

- (UITextField *)searchField
{
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    if ([searchField isKindOfClass:[UITextField class]]) {
        return searchField;
    } else {
        return nil;
    }
}

- (NSOperationQueue *)searchQueue
{
    if (!_searchQueue) {
        _searchQueue = [[NSOperationQueue alloc] init];
        [_searchQueue setMaxConcurrentOperationCount:1];
    }
    return _searchQueue;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _activityIndicator.hidesWhenStopped = NO;
        [_activityIndicator startAnimating];
    }
    return _activityIndicator;
}

- (Song *)closestSong
{
    Song *song;
    if (self.closestSongID) {
        song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:self.closestSongID error:nil];
    }
    return song;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = nil;
    UIEdgeInsets separatorInset = self.tableView.separatorInset;
    separatorInset.right = separatorInset.left;
    self.tableView.separatorInset = separatorInset;

    [self.searchBar setPositionAdjustment:UIOffsetMake(-3, 0) forSearchBarIcon:UISearchBarIconClear];
    self.searchField.rightView = self.activityIndicator;

    self.scrollIndicator.delegate = self;
    
    __weak SearchViewController *weakSelf = self;
    self.observerToken = [[NSNotificationCenter defaultCenter] addObserverForName:kTokenizeProgressNotification
                                                                           object:nil
                                                                            queue:[NSOperationQueue mainQueue]
                                                                       usingBlock:^(NSNotification *note) {
                                                                           NSInteger complete = [note.userInfo[kCompletedSongCountKey] integerValue];
                                                                           NSInteger total = [note.userInfo[kTotalSongCountKey] integerValue];
                                                                           
                                                                           if (complete >= total) {
                                                                               // Clear the progress message.
                                                                               weakSelf.tableView.tableFooterView = nil;
                                                                               [weakSelf.tokenizeProgressView setProgress:0];
                                                                               weakSelf.latestTokenizePercentComplete = 0;
                                                                           } else {
                                                                               // If this is a custom search, show the progress view and activity indicator.
                                                                               if ([weakSelf.searchBar.text length]) {
                                                                                   if (weakSelf.tableView.tableFooterView != weakSelf.tableFooterView) {
                                                                                       weakSelf.tableView.tableFooterView = weakSelf.tableFooterView;
                                                                                   }
                                                                                   weakSelf.searchField.rightViewMode = UITextFieldViewModeAlways;
                                                                                   weakSelf.searchField.clearButtonMode = UITextFieldViewModeNever;
                                                                               }
                                                                               // Update the progress view.
                                                                               [weakSelf.tokenizeProgressView setProgress:(float)complete/(float)total animated:YES];
                                                                           }
                                                                           
                                                                           // Only respond once per whole integer percent value.
                                                                           int percentComplete = (int)floor((float)complete / (float)total * 100);
                                                                           if (percentComplete > weakSelf.latestTokenizePercentComplete) {
                                                                               weakSelf.latestTokenizePercentComplete = percentComplete;

                                                                               // Refresh the search to see if new matches are available.
                                                                               if (percentComplete % 5 == 0 || percentComplete >= 100) {
                                                                                   [weakSelf searchBar:weakSelf.searchBar textDidChange:weakSelf.searchBar.text];
                                                                               }
                                                                           }
                                                                       }];

    [self updateThemedElements];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(self.topBar.frame.size.height - self.view.directionalLayoutMargins.top, 0, 0, 0);
}

- (void)beginSearch
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *preferredSearchMethodNumber = [userDefaults objectForKey:kPreferredSearchMethodKey];
    if (preferredSearchMethodNumber) {
        PreferredSearchMethod preferredSearchMethod = [preferredSearchMethodNumber unsignedIntegerValue];
        if (preferredSearchMethod == PreferredSearchMethodLetters) {
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
        } else if (preferredSearchMethod == PreferredSearchMethodNumbers) {
            self.searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
    }
    
    NSDate *searchTimestamp = [userDefaults objectForKey:kSearchTimestampKey];
    NSTimeInterval searchAge = [[NSDate date] timeIntervalSinceDate:searchTimestamp];
    if (searchAge > 60) {
        self.searchBar.text = nil;
    }
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    
    // This is only used to make the keyboard appear animated.
    [self.hiddenTextField becomeFirstResponder];
    
    // Set search bar as first responder NOT animated to avoid strange cursor animation.
    [UIView setAnimationsEnabled:NO];
    [self.searchBar becomeFirstResponder];
    [UIView setAnimationsEnabled:YES];
}

- (void)endSearch
{
    [self.hiddenTextField resignFirstResponder];
    [self.searchBar resignFirstResponder];
}

- (void)updateThemedElements
{
    self.tableView.backgroundColor = [Theme paperColor];
    self.tableView.separatorColor = [Theme grayTrimColor];
    self.searchField.textColor = [Theme textColor];
    self.activityIndicator.color = [Theme textColor];
    [self.scrollIndicator setNeedsDisplay];
    
    switch ([Theme currentThemeColor]) {
        case ThemeColorLight:
            self.topBarEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            self.searchBar.keyboardAppearance = UIKeyboardAppearanceLight;
            break;
        case ThemeColorDark:
            self.topBarEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
            break;
    }
    
    [self.tableView reloadData];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc
{
    if (self.observerToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observerToken];
    }
}

- (IBAction)searchCancelled:(id)sender
{
    [self endSearch];
    [self.delegate searchCancelled:self];
}

#pragma mark - SearchTableDataSourceDelegate

- (void)selectedSong:(NSManagedObjectID *)selectedSongID withRange:(NSRange)range
{
    [self.searchBar resignFirstResponder];
    [self.delegate searchViewController:self selectedSong:selectedSongID withRange:range];
}

- (void)tableViewScrolled
{
    CGFloat offset = self.tableView.contentOffset.y + self.tableView.contentInset.top;
    CGFloat maxOffset = self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.contentInset.top;
    
    offset = MIN(maxOffset, MAX(0, offset));
    CGFloat percent = offset / maxOffset;
        
    [self.scrollIndicator scrollToPercent:percent];
}

#pragma mark - SuperScrollIndicatorDelegate

- (void)superScrollIndicator:(SuperScrollIndicator *)superScrollIndicator didScrollToPercent:(CGFloat)percent
{
    CGFloat maxOffset = self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.adjustedContentInset.top + self.tableView.adjustedContentInset.bottom;

    CGFloat targetOffset = maxOffset * percent - self.tableView.adjustedContentInset.top;

    [self.tableView setContentOffset:CGPointMake(0, targetOffset) animated:NO];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *workspaceSearchText = searchText;
    if (workspaceSearchText.length == 0) {
        workspaceSearchText = nil;
    }
    
    // Trim whitespace.
    workspaceSearchText = [workspaceSearchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Save the search timestamp.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSDate date] forKey:kSearchTimestampKey];
    
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    self.searchField.clearButtonMode = UITextFieldViewModeNever;

    NSString *letterOnlyString = [workspaceSearchText stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [workspaceSearchText stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];

    // Save the preferred search method.
    if ([letterOnlyString length] > 0) {
        // Letter Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodLetters]
                         forKey:kPreferredSearchMethodKey];
        self.searchBar.keyboardType = UIKeyboardTypeDefault;
    } else if ([decimalDigitOnlyString length] > 0) {
        // Number Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodNumbers]
                         forKey:kPreferredSearchMethodKey];
        self.searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    [userDefaults synchronize];

    SearchOperation *operation = [[SearchOperation alloc] initWithSearchString:workspaceSearchText
                                                                          book:self.closestSong.section.book];
    __weak SearchOperation *weakOperation = operation;
    __weak SearchViewController *weakSelf = self;
    [operation setCompletionBlock:^{
        if (!weakOperation.isCancelled && weakOperation.tableModel) {
            SearchTableModel *tableModel = weakOperation.tableModel;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf updateDataSourceWithTableModel:tableModel];
                [weakSelf.tableView reloadData];
                [weakSelf.scrollIndicator setScrollViewContentHeight:weakSelf.tableView.contentSize.height
                                                      andFrameHeight:weakSelf.tableView.frame.size.height];
                if (weakSelf.tableView.tableFooterView != weakSelf.tableFooterView) {
                    // Only stop animating if the tokenization process has finished.
                    weakSelf.searchField.rightViewMode = UITextFieldViewModeNever;
                    weakSelf.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
                }

                if ((!weakSelf.lastSearchString || [weakSelf.lastSearchString length]) && [workspaceSearchText length] == 0) {
                    // If the search is blank, scroll to the current song.
                    [weakSelf scrollToCurrentSong];
                } else if ((!weakSelf.lastSearchString && workspaceSearchText) ||
                           (weakSelf.lastSearchString && !workspaceSearchText) ||
                           [weakSelf.lastSearchString caseInsensitiveCompare:workspaceSearchText ? workspaceSearchText : @""] != NSOrderedSame) {
                    // If the search text changed (i.e. this was a manual search), Scroll to the top.
                    [weakSelf scrollToTop];
                }
                weakSelf.lastSearchString = workspaceSearchText;
            }];
        }
    }];

    [self.searchQueue cancelAllOperations];
    [self.searchQueue addOperation:operation];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Helper Methods

- (void)updateDataSourceWithTableModel:(SearchTableModel *)tableModel
{
    self.dataSource = [[SearchTableDataSource alloc] initWithTableModel:tableModel];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)scrollToCurrentSong
{
    NSIndexPath *currentSongIndexPath = [self.dataSource indexPathForSongID:self.closestSongID andRange:NSMakeRange(0, 0)];
    
    if (currentSongIndexPath) {
        [self.tableView scrollToRowAtIndexPath:currentSongIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

- (void)scrollToTop
{
    if (self.tableView.numberOfSections > 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

@end
