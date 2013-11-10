//
//  SearchViewController.m
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchViewController.h"
#import "Section.h"
#import "Book.h"
#import "Song+Helpers.h"
#import "SmartSearcher.h"
#import "SearchOperation.h"
#import "SearchTableDataSource.h"
#import "TokenizeOperation.h"

NSString * const kPreferredSearchMethodKey = @"PreferredSearchMethodKey";

typedef enum PreferredSearchMethod : NSUInteger {
    PreferredSearchMethodNumbers,
    PreferredSearchMethodLetters
} PreferredSearchMethod;

@interface SearchViewController () <UITableViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) SearchTableDataSource *dataSource;
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *tokenizeProgressLabel;
@property (nonatomic, strong) id observerToken;

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
    }
    return _activityIndicator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    
    [self updateDataSourceWithTableModel:[SmartSearcher buildModelForSearchString:@""
                                                                           inBook:self.currentSong.section.book
                                                                   shouldContinue:^BOOL{
                                                                       return YES;
                                                                   }]];
    
    self.toolbar.delegate = self;
    
    self.searchField.layer.cornerRadius = 5;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass"]];
    searchImage.frame = CGRectMake(0, 0, 30, 30);
    self.searchField.leftView = searchImage;
    
    self.searchField.rightView = self.activityIndicator;
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    
    self.observerToken = [[NSNotificationCenter defaultCenter] addObserverForName:kTokenizeProgressNotification
                                                                           object:nil
                                                                            queue:[NSOperationQueue mainQueue]
                                                                       usingBlock:^(NSNotification *note) {
                                                                           int complete = [note.userInfo[kCompletedSongCountKey] integerValue];
                                                                           int total = [note.userInfo[kTotalSongCountKey] integerValue];
                                                                           int percentComplete = (int)floor((float)complete / (float)total * 100);
                                                                           self.tokenizeProgressLabel.text = [NSString stringWithFormat:@"%d%%", percentComplete];
                                                                           
                                                                           if (percentComplete >= 100) {
                                                                               self.tokenizeProgressLabel.text = @"";
                                                                               [self searchFieldEditingChanged:self.searchField];
                                                                           }
                                                                       }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDataSourceWithTableModel:[SmartSearcher buildModelForSearchString:@""
                                                                           inBook:self.currentSong.section.book
                                                                   shouldContinue:^BOOL{
                                                                       return YES;
                                                                   }]];
    [self.tableView reloadData];
    [self scrollToCurrentSong];
    
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
    [self.searchField becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectSong"] &&
        [sender isKindOfClass:[UITableViewCell class]]) {
        
        // Get the selected indexPath
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        
        // Get the selected song.
        NSManagedObjectID *songID = [self.dataSource songIDAtIndexPath:selectedIndexPath];
        if (songID) {
            Song *song = (Song *)[self.currentSong.managedObjectContext existingObjectWithID:songID error:NULL];
            
            // Maintain a reference to the selected song.
            self.selectedSong = song;
            
            // Remember which location in the song was selected.
            self.selectedRange = [self.dataSource songRangeAtIndexPath:selectedIndexPath];
        }
        
        [self.searchField resignFirstResponder];
    }
}

- (void)dealloc
{
    if (self.observerToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observerToken];
    }
}

#pragma mark - UISearchBarDelegate

- (IBAction)searchFieldEditingChanged:(UITextField *)sender {

    if (!self.activityIndicator.isAnimating) {
        [self.activityIndicator startAnimating];
    }
    
    NSString *searchText = sender.text;
    
    NSString *letterOnlyString = [searchText stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchText stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([letterOnlyString length] > 0) {
        // Letter Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodLetters]
                         forKey:kPreferredSearchMethodKey];
    } else if ([decimalDigitOnlyString length] > 0) {
        // Number Search
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:PreferredSearchMethodNumbers]
                         forKey:kPreferredSearchMethodKey];
    }
    [userDefaults synchronize];
    
    SearchOperation *operation = [[SearchOperation alloc] initWithSearchString:searchText
                                                                        bookID:self.currentSong.section.book.objectID
                                                              storeCoordinator:self.currentSong.managedObjectContext.persistentStoreCoordinator];
    __weak SearchOperation *weakOperation = operation;
    __weak SearchViewController *weakSelf = self;
    [operation setCompletionBlock:^{
        
        if (!weakOperation.isCancelled && weakOperation.tableModel) {
            SearchTableModel *tableModel = weakOperation.tableModel;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"search operation completed");
                [weakSelf updateDataSourceWithTableModel:tableModel];
                [weakSelf.tableView reloadData];
                
//                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
                [self.activityIndicator stopAnimating];
            });
        }
    }];
    
    [self.searchQueue cancelAllOperations];
    [self.searchQueue addOperation:operation];
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionAny;
}

#pragma mark - Helper Methods

- (void)updateDataSourceWithTableModel:(SearchTableModel *)tableModel
{
    self.dataSource = [[SearchTableDataSource alloc] initWithTableModel:tableModel];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)scrollToCurrentSong
{
    NSIndexPath *currentSongIndexPath = [self.dataSource indexPathForSongID:self.currentSong.objectID];
    
    if (currentSongIndexPath) {
        [self.tableView scrollToRowAtIndexPath:currentSongIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

@end
