//
//  SplitViewController.h
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "CoreDataStack.h"
#import "PageViewController.h"

@interface SplitViewController : UIViewController <PageViewControllerDelegate>

@property (nonatomic) BOOL searchHidden;
@property (nonatomic, strong) CoreDataStack *coreDataStack;

@end