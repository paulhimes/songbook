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

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    [self.searchBar becomeFirstResponder];
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
        Section *sectionOfSelectedSong = self.currentSong.section.book.sections[selectedIndexPath.section];
        Song *selectedSong = sectionOfSelectedSong.songs[selectedIndexPath.row];

        // Maintain a reference to the selected song.
        self.selectedSong = selectedSong;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"CancelSearch" sender:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.currentSong.section.book.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sectionAtIndex = self.currentSong.section.book.sections[section];
    return sectionAtIndex.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sectionForTableSection = self.currentSong.section.book.sections[section];
    return [sectionForTableSection.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionForTableSection = self.currentSong.section.book.sections[indexPath.section];
    Song *songForRow = sectionForTableSection.songs[indexPath.row];

    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:30];
    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:22];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                         attributes:nil];
    if (songForRow.number) {
        [attributedString appendString:[NSString stringWithFormat:@"%d", [songForRow.number integerValue]]attributes:numberAttributes];
        [attributedString appendString:@" " attributes:titleAttributes];
    }
    
    [attributedString appendString:songForRow.title attributes:titleAttributes];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    cell.textLabel.attributedText = attributedString;
    
    return cell;
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
        self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, endFrame.size.height, 0);
    } completion:^(BOOL finished) {}];
}

- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
    } completion:^(BOOL finished) {}];
}

@end
