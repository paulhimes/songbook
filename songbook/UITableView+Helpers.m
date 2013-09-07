//
//  UITableView+Helpers.m
//  songbook
//
//  Created by Paul Himes on 9/7/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "UITableView+Helpers.h"

@implementation UITableView (Helpers)

- (CGFloat)contentHeight
{
    CGFloat height = 0;
    
    height += self.tableHeaderView.frame.size.height;
    
    NSInteger numberOfSections = [self numberOfSections];
    
    for (NSInteger i = 0; i < numberOfSections; i++) {
        height += [self rectForSection:i].size.height;
    }
    
    height += self.tableFooterView.frame.size.height;
    
    return height;
}

@end
