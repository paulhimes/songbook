//
//  SearchViewController.h
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@protocol SearchViewControllerDelegate;

@interface SearchViewController : UIViewController

@property (nonatomic, strong) Song *currentSong;
@property (nonatomic, strong) Song *selectedSong;
@property (nonatomic) NSUInteger selectedLocation;

@end

@protocol SearchViewControllerDelegate <NSObject>

@end