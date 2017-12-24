//
//  SearchViewController.m
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchViewController.h"
#import "Section.h"
#import "Song.h"
#import "SmartSearcher.h"
#import "SearchOperation.h"
#import "SearchTableDataSource.h"
#import "TokenizeOperation.h"
#import "SuperScrollIndicator.h"

static NSString * const kPreferredSearchMethodKey = @"PreferredSearchMethodKey";
static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kClosestSongIDKey = @"ClosestSongIDKey";
static NSString * const kSearchStringKey = @"SearchStringKey";
static NSString * const kSearchTimestampKey = @"SearchTimestampKey";
static NSString * const kDelegateKey = @"DelegateKey";

typedef enum PreferredSearchMethod : NSUInteger {
    PreferredSearchMethodNumbers,
    PreferredSearchMethodLetters
} PreferredSearchMethod;

@interface SearchViewController () <UITableViewDelegate, SearchTableDataSourceDelegate, UITextFieldDelegate, SuperScrollIndicatorDelegate>

@property (nonatomic, strong) SearchTableDataSource *dataSource;
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *lastSearchString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (weak, nonatomic) IBOutlet SuperScrollIndicator *scrollIndicator;

@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIProgressView *tokenizeProgressView;
@property (nonatomic) NSUInteger latestTokenizePercentComplete;
@property (nonatomic, strong) id observerToken;

@property (nonatomic, readonly) Song *closestSong;

@end

@implementation SearchViewController

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
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        CGRect frame = _activityIndicator.frame;
        _activityIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + 10, frame.size.height);
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
    self.tableView.backgroundColor = [Theme paperColor];
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 20;
    
    self.searchField.layer.cornerRadius = 5;
    self.searchField.backgroundColor = [Theme searchFieldBackgroundColor];
    self.searchField.textColor = [Theme textColor];
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass"]];
    searchImage.frame = CGRectMake(0, 0, 30, 30);
    self.searchField.leftView = searchImage;
    
    self.searchField.rightView = self.activityIndicator;
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    
    self.searchField.delegate = self;
    
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
                                                                               if ([weakSelf.searchField.text length]) {
                                                                                   if (weakSelf.tableView.tableFooterView != weakSelf.tableFooterView) {
                                                                                       weakSelf.tableView.tableFooterView = weakSelf.tableFooterView;
                                                                                   }
                                                                                   if (!weakSelf.activityIndicator.isAnimating) {
                                                                                       self.searchField.rightView = self.activityIndicator;
                                                                                       [weakSelf.activityIndicator startAnimating];
                                                                                   }
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
                                                                                   [weakSelf searchFieldEditingChanged:weakSelf.searchField];
                                                                               }
                                                                           }
                                                                       }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(self.topBar.frame.size.height - self.topLayoutGuide.length, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *preferredSearchMethodNumber = [userDefaults objectForKey:kPreferredSearchMethodKey];
    if (preferredSearchMethodNumber) {
        PreferredSearchMethod preferredSearchMethod = [preferredSearchMethodNumber unsignedIntegerValue];
        if (preferredSearchMethod == PreferredSearchMethodLetters) {
            self.searchField.keyboardType = UIKeyboardTypeDefault;
        } else if (preferredSearchMethod == PreferredSearchMethodNumbers) {
            self.searchField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
    }
    
    NSDate *searchTimestamp = [userDefaults objectForKey:kSearchTimestampKey];
    NSTimeInterval searchAge = [searchTimestamp timeIntervalSinceNow];
    if (searchAge > -60) {
        NSString *searchString = [userDefaults stringForKey:kSearchStringKey];
        self.searchField.text = searchString;
    }
    [self searchFieldEditingChanged:self.searchField];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Save the search string and timestamp.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.searchField.text forKey:kSearchStringKey];
    [userDefaults setObject:[NSDate date] forKey:kSearchTimestampKey];
    [userDefaults synchronize];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    if (self.observerToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observerToken];
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    
    if (self.closestSongID) {
        [coder encodeObject:[self.closestSongID URIRepresentation] forKey:kClosestSongIDKey];
    }
    
    [coder encodeObject:self.searchField.text forKey:kSearchStringKey];
    
    // Save the delegate
    if (self.delegate) {
        [coder encodeObject:self.delegate forKey:kDelegateKey];
    }
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.delegate = [coder decodeObjectForKey:kDelegateKey];
    
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    NSURL *closestSongIDURL = [coder decodeObjectForKey:kClosestSongIDKey];
    self.closestSongID = [self.coreDataStack.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:closestSongIDURL];
    
    NSString *searchString = [coder decodeObjectForKey:kSearchStringKey];
    if (searchString) {
        self.searchField.text = searchString;
        [self searchFieldEditingChanged:self.searchField];
    }
}

- (IBAction)searchCancelled:(id)sender
{
    [self.delegate searchCancelled:self];
}

#pragma mark - UISearchBarDelegate

- (IBAction)searchFieldEditingChanged:(UITextField *)sender {

    if (!self.activityIndicator.isAnimating) {
        self.searchField.rightView = self.activityIndicator;
        [self.activityIndicator startAnimating];
    }
    
    NSString *searchText = self.searchField.text;
    
    NSString *letterOnlyString = [searchText stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchText stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // Save the preferred search method.
    if ([letterOnlyString length] > 0) {
        // Letter Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodLetters]
                         forKey:kPreferredSearchMethodKey];
        self.searchField.keyboardType = UIKeyboardTypeDefault;
        [self.searchField resignFirstResponder];
        [self.searchField becomeFirstResponder];
    } else if ([decimalDigitOnlyString length] > 0) {
        // Number Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodNumbers]
                         forKey:kPreferredSearchMethodKey];
        self.searchField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [self.searchField resignFirstResponder];
        [self.searchField becomeFirstResponder];
    }
    [userDefaults synchronize];
    
    SearchOperation *operation = [[SearchOperation alloc] initWithSearchString:searchText
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
                    [weakSelf.activityIndicator stopAnimating];
                    weakSelf.searchField.rightView = nil;
                }
                
                if ((!weakSelf.lastSearchString || [weakSelf.lastSearchString length]) && [searchText length] == 0) {
                    // If the search is blank, scroll to the current song.
                    [weakSelf scrollToCurrentSong];
                } else if ((!weakSelf.lastSearchString && searchText) ||
                           (weakSelf.lastSearchString && !searchText) ||
                           [weakSelf.lastSearchString caseInsensitiveCompare:searchText ? searchText : @""] != NSOrderedSame) {
                    // If the search text changed (i.e. this was a manual search), Scroll to the top.
                    [weakSelf scrollToTop];
                }
                weakSelf.lastSearchString = searchText;
            }];
        }
    }];
    
    [self.searchQueue cancelAllOperations];
    [self.searchQueue addOperation:operation];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SearchTableDataSourceDelegate

- (void)selectedSong:(NSManagedObjectID *)selectedSongID withRange:(NSRange)range
{
    [self.delegate searchViewController:self selectedSong:selectedSongID withRange:range];
    [self.searchField resignFirstResponder];
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
    CGFloat maxOffset = maxOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
    
    if (@available(iOS 11, *)) {
        maxOffset += self.tableView.adjustedContentInset.top + self.tableView.adjustedContentInset.bottom;
    } else {
        maxOffset += self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    }
    
    CGFloat targetOffset = maxOffset * percent;
    
    if (@available(iOS 11, *)) {
        targetOffset -= self.tableView.adjustedContentInset.top;
    } else {
        targetOffset -= self.tableView.contentInset.top;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, targetOffset) animated:NO];
    [self.searchField resignFirstResponder];
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
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

@end
