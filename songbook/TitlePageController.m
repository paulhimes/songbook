//
//  TitlePageController.m
//  songbook
//
//  Created by Paul Himes on 8/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageController.h"

@interface TitlePageController ()

@end

@implementation TitlePageController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    [self.textView setHeight:textSize.height];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom), textSize.height));
}

@end
