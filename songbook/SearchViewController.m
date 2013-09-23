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
#import "SmartSearchDataSource.h"

NSString * const kPreferredSearchMethodKey = @"PreferredSearchMethodKey";

typedef enum PreferredSearchMethod : NSUInteger {
    PreferredSearchMethodNumbers,
    PreferredSearchMethodLetters
} PreferredSearchMethod;

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) id<SearchDataSource> searchDataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    
    [self setDataSourceWithSearchString:@""];
    
    self.toolbar.delegate = self;
    self.searchField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        Song *selectedSong = [self.searchDataSource songAtIndexPath:selectedIndexPath];

        // Maintain a reference to the selected song.
        self.selectedSong = selectedSong;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"CancelSearch" sender:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
    
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    [self setDataSourceWithSearchString:searchText];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"search update took %f seconds", endTime - startTime);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionAny;
}

#pragma mark - Helper Methods

- (void)setDataSourceWithSearchString:(NSString *)searchString
{
    self.searchDataSource = [[SmartSearchDataSource alloc] initWithBook:self.currentSong.section.book searchString:searchString];
    self.tableView.dataSource = self.searchDataSource;
    self.tableView.delegate = self.searchDataSource;
}

- (void)scrollToCurrentSong
{
    NSIndexPath *currentSongIndexPath = [self.searchDataSource indexPathForSong:self.currentSong];
    
    if (currentSongIndexPath) {
        [self.tableView scrollToRowAtIndexPath:currentSongIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

@end
