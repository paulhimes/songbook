//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"

@interface PageController : UIViewController

@property (nonatomic, readonly) NSManagedObject *modelObject;

- (PageView *)buildPageView;

@end
