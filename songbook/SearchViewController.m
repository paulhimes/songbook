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

static NSString * const kPreferredSearchMethodKey = @"PreferredSearchMethodKey";
static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kClosestSongIDKey = @"ClosestSongIDKey";
static NSString * const kSearchStringKey = @"SearchStringKey";

typedef enum PreferredSearchMethod : NSUInteger {
    PreferredSearchMethodNumbers,
    PreferredSearchMethodLetters
} PreferredSearchMethod;

@interface SearchViewController () <UITableViewDelegate, UIToolbarDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) SearchTableDataSource *dataSource;
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *tokenizeProgressLabel;
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
    }
    return _activityIndicator;
}

- (Song *)closestSong
{
    NSError *getSongError;
    Song *song;
    if (self.closestSongID) {
        song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:self.closestSongID error:&getSongError];
    }
    return song;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.restorationClass = [self class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.frame.size.height, 0, 0, 0);

    self.toolbar.delegate = self;
    
    self.searchField.layer.cornerRadius = 5;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass"]];
    searchImage.frame = CGRectMake(0, 0, 30, 30);
    self.searchField.leftView = searchImage;
    
    self.searchField.rightView = self.activityIndicator;
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    
    __weak SearchViewController *weakSelf = self;
    self.observerToken = [[NSNotificationCenter defaultCenter] addObserverForName:kTokenizeProgressNotification
                                                                           object:nil
                                                                            queue:[NSOperationQueue mainQueue]
                                                                       usingBlock:^(NSNotification *note) {
                                                                           int complete = [note.userInfo[kCompletedSongCountKey] integerValue];
                                                                           int total = [note.userInfo[kTotalSongCountKey] integerValue];
                                                                           int percentComplete = (int)floor((float)complete / (float)total * 100);
                                                                           
                                                                           // Only respond once per whole integer percent value.
                                                                           if (percentComplete > weakSelf.latestTokenizePercentComplete) {
                                                                               weakSelf.latestTokenizePercentComplete = percentComplete;
                                                                               if (percentComplete >= 100) {
                                                                                   // Clear the progress message.
                                                                                   weakSelf.tokenizeProgressLabel.text = @"";
                                                                                   weakSelf.latestTokenizePercentComplete = 0;
                                                                               } else {
                                                                                   // Update the progress message.
                                                                                   weakSelf.tokenizeProgressLabel.text = [NSString stringWithFormat:@"%d%%", percentComplete];
                                                                               }
                                                                               
                                                                               // Refresh the search to see if new matches are available.
                                                                               if (percentComplete % 5 == 0 || percentComplete >= 100) {
                                                                                   [weakSelf searchFieldEditingChanged:weakSelf.searchField];
                                                                               }
                                                                           }
                                                                       }];
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
//    [self.searchField becomeFirstResponder];
    
    [self searchFieldEditingChanged:self.searchField];
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
        self.selectedSongID = [self.dataSource songIDAtIndexPath:selectedIndexPath];
        
        // Remember which location in the song was selected.
        self.selectedRange = [self.dataSource songRangeAtIndexPath:selectedIndexPath];
        
        [self.searchField resignFirstResponder];
    }
}

- (void)dealloc
{
    if (self.observerToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observerToken];
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"Encode SearchViewController");
    
    if (self.coreDataStack) {
        [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    }
    
    if (self.closestSongID) {
        [coder encodeObject:[self.closestSongID URIRepresentation] forKey:kClosestSongIDKey];
    }
    
    [coder encodeObject:self.searchField.text forKey:kSearchStringKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    SearchViewController *controller;
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    CoreDataStack *coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    NSURL *closestSongIDURL = [coder decodeObjectForKey:kClosestSongIDKey];
    NSManagedObjectID *closestSongID = [coreDataStack.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:closestSongIDURL];
    
    if (storyboard && coreDataStack) {
        NSLog(@"Created SearchViewController");
        
        controller = (SearchViewController *)[storyboard instantiateViewControllerWithIdentifier:[identifierComponents lastObject]];
        controller.coreDataStack = coreDataStack;
        controller.closestSongID = closestSongID;
    }
    
    return controller;
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSString *searchString = [coder decodeObjectForKey:kSearchStringKey];
    if (searchString) {
        self.searchField.text = searchString;
        [self searchFieldEditingChanged:self.searchField];
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
                                                                          book:self.closestSong.section.book];
    __weak SearchOperation *weakOperation = operation;
    __weak SearchViewController *weakSelf = self;
    [operation setCompletionBlock:^{
        if (!weakOperation.isCancelled && weakOperation.tableModel) {
            SearchTableModel *tableModel = weakOperation.tableModel;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"search operation completed");
                [weakSelf updateDataSourceWithTableModel:tableModel];
                [weakSelf.tableView reloadData];
                [weakSelf.activityIndicator stopAnimating];
                
                if ([searchText length] == 0) {
                    [weakSelf scrollToCurrentSong];
                }
            }];
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
    NSIndexPath *currentSongIndexPath = [self.dataSource indexPathForSongID:self.closestSongID andRange:NSMakeRange(0, 0)];
    
    if (currentSongIndexPath) {
        [self.tableView scrollToRowAtIndexPath:currentSongIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

@end
