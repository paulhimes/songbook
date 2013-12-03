//
//  SingleViewController.h
//  songbook
//
//  Created by Paul Himes on 11/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@interface SingleViewController : UIViewController <PageViewControllerDelegate>

@property (nonatomic, strong) CoreDataStack *coreDataStack;

@end
