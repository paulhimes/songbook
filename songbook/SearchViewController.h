//
//  SearchViewController.h
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataStack.h"
#import "Song.h"

@interface SearchViewController : UIViewController

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) NSManagedObjectID *closestSongID;
@property (nonatomic, strong) NSManagedObjectID *selectedSongID;
@property (nonatomic) NSRange selectedRange;

@end