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

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<SearchDataSource> searchDataSource;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation SearchViewController

- (id<SearchDataSource>)searchDataSource
{
    if (!_searchDataSource) {
        _searchDataSource = [[SmartSearchDataSource alloc] initWithBook:self.currentSong.section.book];
    }
    return _searchDataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    self.tableView.dataSource = self.searchDataSource;
    self.tableView.delegate = self.searchDataSource;
    
    self.toolbar.delegate = self;
    self.searchField.delegate = self;
    
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 258, 44)];
//    ;
    
//    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 258, 30)];
//    searchField.backgroundColor = [UIColor whiteColor];
//    
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchField];
//
//    
//    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:nil];
//    
//    self.toolbar.items = @[
//                           searchItem,
//                           cancelItem
//                           ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToCurrentSong];
    [self registerForKeyboardNotifications];
    [self.searchField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unregisterForKeyboardNotifications];
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
    [self.searchDataSource setSearchString:searchText];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Keyboard adjustment methods

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect endFrame;
    [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
    endFrame = [self.tableView convertRect:endFrame fromView:nil];
        
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, endFrame.size.height, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, endFrame.size.height, 0);
        [self scrollToCurrentSong];
    } completion:^(BOOL finished) {}];
}

- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    } completion:^(BOOL finished) {}];
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionAny;
}

#pragma mark - Helper Methods

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
